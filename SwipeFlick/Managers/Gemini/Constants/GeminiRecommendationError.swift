import Foundation

enum GeminiRecommendationError: LocalizedError {
    case emptyResponse
    case ambiguousResponse(String)
    case conflictsWithDisliked(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "geminiErrorEmptyResponse".translated
        case .ambiguousResponse:
            return "geminiErrorAmbiguousResponse".translated
        case .conflictsWithDisliked(let title):
            return String(format: "geminiErrorDislikedConflict".translated, title)
        }
    }
    
    var failureReason: String? {
        switch self {
        case .ambiguousResponse(let rawResponse):
            return rawResponse
        default:
            return nil
        }
    }
}
