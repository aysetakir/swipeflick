import Foundation
import FirebaseAI

struct GeminiRecommendationConfiguration {
    let modelName: String
    let generationConfig: GenerationConfig
    let maxRetryCount: Int
    let retryDelay: TimeInterval
    
    /// Varsayılan yapılandırma, film önerileri için tek ve deterministik yanıt üretmeye odaklanır.
    /// - Parametreler Google Gemini dokümanlarına dayanır: düşük temperature deterministik sonuç verir, topP/topK çeşitliliği sınırlar, `maxOutputTokens` gereksiz uzun yanıtları engeller.
    static let `default` = GeminiRecommendationConfiguration(
        modelName: "gemini-2.0-flash",
        generationConfig: GenerationConfig(
            temperature: 0.35,
            topP: 0.9,
            topK: 32,
            maxOutputTokens: 32
        ),
        maxRetryCount: 2,
        retryDelay: 0.75
    )
    
    init(modelName: String,
         generationConfig: GenerationConfig,
         maxRetryCount: Int = 2,
         retryDelay: TimeInterval = 0.75) {
        self.modelName = modelName
        self.generationConfig = generationConfig
        self.maxRetryCount = max(1, maxRetryCount)
        self.retryDelay = max(0, retryDelay)
    }
}
