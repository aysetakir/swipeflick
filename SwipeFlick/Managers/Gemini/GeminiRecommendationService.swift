import Foundation
import FirebaseAI

protocol GeminiRecommendationServicing {
    func recommend(using request: GeminiRecommendationRequest) async throws -> GeminiRecommendation
}

final class GeminiRecommendationService: GeminiRecommendationServicing {
    private let config: GeminiRecommendationConfiguration
    private let model: GenerativeModel
    private let promptBuilder = PromptBuilder()
    
    init(configuration: GeminiRecommendationConfiguration = .default) {
        self.config = configuration
        let systemInstruction = ModelContent(
            role: "system",
            parts: [
                TextPart("""
You are SwipeFlick's senior film recommendation engine. Your job is to study a viewer's taste profile and propose one single existing feature film they are likely to enjoy next. Always follow these rules:
1. Respond with exactly one film title.
2. Do not include any explanation, punctuation, numbering, emojis, extra text, or quotes.
3. Never suggest a film that appears in the disliked list.
4. Align the suggestion with the liked titles and overall tone implied by the provided context, avoiding the disliked titles.
5. When a locale is provided, output the official title for that locale if available; otherwise return the original release title.
""")
            ]
        )
        
        model = FirebaseAI.firebaseAI().generativeModel(
            modelName: configuration.modelName,
            generationConfig: configuration.generationConfig,
            systemInstruction: systemInstruction
        )
    }
    
    func recommend(using request: GeminiRecommendationRequest) async throws -> GeminiRecommendation {
        let sanitizedRequest = sanitize(request: request)
        let prompt = promptBuilder.makePrompt(for: sanitizedRequest)
        
        for attempt in 1...config.maxRetryCount {
            do {
                let response = try await model.generateContent(prompt)
                guard let rawText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !rawText.isEmpty else {
                    throw GeminiRecommendationError.emptyResponse
                }
                
                let title = sanitizeResponse(rawText)
                try validate(title: title, against: sanitizedRequest, rawResponse: rawText)
                
                return GeminiRecommendation(title: title)
            } catch {
                if attempt < config.maxRetryCount && shouldRetry(after: error) {
                    let delay = UInt64(config.retryDelay * Double(NSEC_PER_SEC))
                    try await Task.sleep(nanoseconds: delay)
                    continue
                }
                throw error
            }
        }
        throw GeminiRecommendationError.emptyResponse
    }
}

private extension GeminiRecommendationService {
    struct PreparedRequest {
        let likedTitles: [String]
        let dislikedTitles: [String]
        let additionalContext: String?
        let localeIdentifier: String
    }
    
    func sanitize(request: GeminiRecommendationRequest) -> PreparedRequest {
        let localeIdentifier = request.locale.identifier
        let dislikedTitles = sanitize(titles: request.dislikedTitles)
        return PreparedRequest(
            likedTitles: sanitize(titles: request.likedTitles),
            dislikedTitles: dislikedTitles,
            additionalContext: request.additionalContext?.trimmingCharacters(in: .whitespacesAndNewlines),
            localeIdentifier: localeIdentifier
        )
    }
    
    func sanitize(titles: [String], limit: Int = 20) -> [String] {
        sanitize(terms: titles, limit: limit)
    }
    
    func sanitize(terms: [String], limit: Int = 10) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        
        for term in terms {
            let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else { continue }
            let key = normalized.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                result.append(normalized)
            }
            if result.count == limit { break }
        }
        return result
    }
    
    func sanitizeResponse(_ raw: String) -> String {
        let firstLine = raw
            .components(separatedBy: .newlines)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? raw
        
        let withoutQuotes = firstLine.trimmingCharacters(in: CharacterSet(charactersIn: "\"'“”`"))
        
        let pattern = #"^[\-\d\.\)\(]+[\s]*"#
        let cleaned: String
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: withoutQuotes.utf16.count)
            cleaned = regex.stringByReplacingMatches(in: withoutQuotes, options: [], range: range, withTemplate: "")
        } else {
            cleaned = withoutQuotes
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func validate(title: String, against request: PreparedRequest, rawResponse: String) throws {
        guard !title.isEmpty,
              title.rangeOfCharacter(from: .newlines) == nil else {
            throw GeminiRecommendationError.ambiguousResponse(rawResponse)
        }
        
        guard title.rangeOfCharacter(from: CharacterSet.letters) != nil else {
            throw GeminiRecommendationError.ambiguousResponse(rawResponse)
        }
        
        let dislikedLookup = Set(request.dislikedTitles.map { normalizedKey(for: $0, localeIdentifier: request.localeIdentifier) })
        let key = normalizedKey(for: title, localeIdentifier: request.localeIdentifier)
        if dislikedLookup.contains(key) {
            throw GeminiRecommendationError.conflictsWithDisliked(title)
        }
    }
    
    func normalizedKey(for value: String, localeIdentifier: String) -> String {
        let locale = Locale(identifier: localeIdentifier)
        let folded = value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: locale)
        let pattern = #"\s+"#
        let normalized: String
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: folded.utf16.count)
            normalized = regex.stringByReplacingMatches(in: folded, options: [], range: range, withTemplate: " ")
        } else {
            normalized = folded
        }
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func shouldRetry(after error: Error) -> Bool {
        if let nsError = error as NSError? {
            if nsError.domain == NSURLErrorDomain {
                let retriableCodes: Set<Int> = [
                    URLError.timedOut.rawValue,
                    URLError.cannotFindHost.rawValue,
                    URLError.cannotConnectToHost.rawValue,
                    URLError.networkConnectionLost.rawValue,
                    URLError.notConnectedToInternet.rawValue
                ]
                return retriableCodes.contains(nsError.code)
            }
            if nsError.domain == "com.google.HTTPStatus" || nsError.domain == "com.google.GPBFIRHTTPErrorDomain" {
                if nsError.code == 429 || (500...599).contains(nsError.code) {
                    return true
                }
            }
        }
        return false
    }
}

private extension GeminiRecommendationService {
    struct PromptBuilder {
        func makePrompt(for request: PreparedRequest) -> String {
            var sections: [String] = []
            
            sections.append("User locale: \(request.localeIdentifier)")
            
            if !request.likedTitles.isEmpty {
                sections.append("""
Movies the viewer enjoyed:
\(bulletList(request.likedTitles))
""")
            } else {
                sections.append("Movies the viewer enjoyed: (not provided)")
            }
            
            if !request.dislikedTitles.isEmpty {
                sections.append("""
Movies the viewer disliked:
\(bulletList(request.dislikedTitles))
""")
            } else {
                sections.append("Movies the viewer disliked: (not provided)")
            }
            
            if let context = request.additionalContext, !context.isEmpty {
                sections.append("Additional context: \(context)")
            }
            
            sections.append("""
Produce your recommendation now. Follow the system rules strictly: output only the movie title, with no surrounding text.
""")
            
            return sections.joined(separator: "\n\n")
        }
        
        private func bulletList(_ values: [String]) -> String {
            values.map { "- \($0)" }.joined(separator: "\n")
        }
    }
}
