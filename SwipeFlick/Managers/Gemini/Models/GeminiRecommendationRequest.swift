import Foundation

struct GeminiRecommendationRequest {
    let likedTitles: [String]
    let dislikedTitles: [String]
    let additionalContext: String?
    let locale: Locale
    
    init(likedTitles: [String],
         dislikedTitles: [String],
         additionalContext: String? = nil,
         locale: Locale = Locale(identifier: "en_US")) {
        self.likedTitles = likedTitles
        self.dislikedTitles = dislikedTitles
        self.additionalContext = additionalContext
        self.locale = locale
    }
}
