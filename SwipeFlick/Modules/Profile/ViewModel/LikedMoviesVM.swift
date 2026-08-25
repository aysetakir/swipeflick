import Foundation

protocol LikedMoviesVMProtocol: AnyObject {
    var onMoviesLoaded: (([Movie]) -> Void)? { get set }
    var onLoadingStateChange: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    func loadLikedMovies()
}

@MainActor
final class LikedMoviesVM: LikedMoviesVMProtocol {
    private let preferencesManager: UserPreferencesManaging

    var onMoviesLoaded: (([Movie]) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(preferencesManager: UserPreferencesManaging? = nil) {
        self.preferencesManager = preferencesManager ?? FirebaseUserPreferencesManager.shared
    }

    func loadLikedMovies() {
        onLoadingStateChange?(true)

        preferencesManager.fetchAIPickMovies { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                self.onLoadingStateChange?(false)

                switch result {
                case .success(let movies):
                    self.onMoviesLoaded?(movies)
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
