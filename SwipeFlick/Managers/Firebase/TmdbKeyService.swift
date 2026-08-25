import Foundation
import FirebaseFunctions

final class TmdbKeyService {
    static let shared = TmdbKeyService()
    private let functions: Functions

    private init() {
        self.functions = Functions.functions(region: "europe-west1")
    }

    func fetchKey(completion: @escaping (Result<String, Error>) -> Void) {
        functions.httpsCallable("getTmdbKey").call { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard
                let data = result?.data as? [String: Any],
                let key = data["key"] as? String
            else {
                completion(.failure(NSError(domain: "TmdbKeyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])) )
                return
            }
            completion(.success(key))
        }
    }
}

