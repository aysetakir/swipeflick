import Foundation

protocol DiscoverVMProtocol {
    var movies: [Movie] { get }
    var genres: [Genre] { get }
    var numberOfMovies: Int { get }
    
    var onMoviesUpdated: (() -> Void)? { get set }
    var onMoviesAppended: ((Int) -> Void)? { get set }
    var onGenresUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func movie(at index: Int) -> Movie
    func setGenre(_ genreID: Int?)
    func fetchGenres() async
    func fetchMovies(page: Int) async
}

@MainActor
final class DiscoverVM: DiscoverVMProtocol {
    private(set) var movies: [Movie] = []
    private(set) var genres: [Genre] = []
    private var selectedGenreID: Int? = nil
    var currentPage = 1
    var totalPages = 1
    
    var numberOfMovies: Int {
        movies.count
    }
    
    var onMoviesUpdated: (() -> Void)?
    var onMoviesAppended: ((Int) -> Void)?
    var onGenresUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    func movie(at index: Int) -> Movie {
        movies[index]
    }
    
    func setGenre(_ genreID: Int?) {
        selectedGenreID = genreID
        currentPage = 1
        Task {
            await fetchMovies(page: 1)
        }
    }
    
    func fetchGenres() {
        Task {
            do {
                let fetchedGenres = try await NetworkManager.shared.fetchGenres()
                self.genres = fetchedGenres
                onGenresUpdated?()
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
    
    func fetchMovies(page: Int = 1) async {
        onLoadingStateChanged?(true)
        
        do {
            let response: ([Movie], Int)
            
            if let genreID = selectedGenreID {
                response = try await NetworkManager.shared.fetchMoviesByGenre(genreID: genreID, page: page)
            } else {
                response = try await NetworkManager.shared.fetchMovies(page: page)
            }
            
            let (newMovies, total) = response
            totalPages = total
            
            if page == 1 {
                movies = newMovies
                onMoviesUpdated?()
            } else {
                let addedCount = newMovies.count
                movies.append(contentsOf: newMovies)
                onMoviesAppended?(addedCount)
            }
            
            currentPage = page
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
        case .invalidURL:
            message = "invalid_url".translated
        case .invalidResponse:
            message = "invalid_response".translated
        case .noData:
            message = "no_data".translated
        case .httpError(let code):
            message = "http_error".translated + ": \(code)"
        }
        onError?(message)
    }
}
