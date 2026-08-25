import Foundation

protocol MovieDetailVMProtocol {
    var movie: MovieDetail? { get }
    
    var onMovieDetailUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func fetchDetail() async
    func formatRuntime(_ minutes: Int) -> String
}

@MainActor
final class MovieDetailVM: MovieDetailVMProtocol {
    private(set) var movie: MovieDetail?
    
    var onMovieDetailUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    private let movieId: Int
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    func fetchDetail() async {
        onLoadingStateChanged?(true)
        do {
            let movie = try await NetworkManager.shared.fetchMovieDetail(id: movieId)
            self.movie = movie
            onMovieDetailUpdated?()
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        onLoadingStateChanged?(false)
    }
    
    private func handleError(_ error: NetworkError) {
        let message: String
        switch error {
        case .invalidURL: message = "invalid_url".translated
        case .invalidResponse: message = "invalid_response".translated
        case .noData: message = "no_data".translated
        case .httpError(let code): message = "http_error".translated + ": \(code)"
        }
        onError?(message)
    }
    
    func formatRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}
