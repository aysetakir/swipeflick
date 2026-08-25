import Foundation

protocol HomeVMProtocol {
    var movies: [Movie] { get }
    var genres: [Genre] { get }
    var likedMovies: [Movie] { get set }
    var dislikedMovies: [Movie] { get set }
    var swipeCount: Int { get set }
    var onMoviesUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func fetchMovies() async
    func fetchGenres() async
    func getNextMovie() async -> Movie?
    func getMovieByName(name: String) async throws -> Movie?
    func fetchDetail(for id: Int) async -> MovieDetail?
    func formatRuntime(_ minutes: Int) -> String
    func formatReleaseDate(_ date: String) -> String
    func saveLikedMovie(_ movie: Movie)
    func saveDislikedMovie(_ movie: Movie)
    func saveAIPickMovie(_ movie: Movie)
}

@MainActor
final class HomeVM: HomeVMProtocol {
    var likedMovies: [Movie] = []
    var dislikedMovies: [Movie] = []
    var swipeCount: Int = 0
    var movieIndex: Int = 0
    var totalPages: Int = 1
    
    private(set) var movies: [Movie] = []
    private(set) var genres: [Genre] = []

    private var detailsCache: [Int: MovieDetail] = [:]
    private let preferencesManager: UserPreferencesManaging
    private let authManager: AuthManaging

    var onMoviesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    init(preferencesManager: UserPreferencesManaging? = nil,
         authManager: AuthManaging? = nil) {
        self.preferencesManager = preferencesManager ?? FirebaseUserPreferencesManager.shared
        self.authManager = authManager ?? FirebaseAuthManager.shared
    }

    func fetchMovies() async {
        onLoadingStateChanged?(true)
        do {
            if totalPages <= 1 { totalPages = 500 }
            let randomPage = Int.random(in: 1...totalPages)
            print("Fetching movies from random page: \(randomPage)")
            
            let (_movies, newTotalPages) = try await NetworkManager.shared.fetchMovies(page: randomPage)
            totalPages = min(newTotalPages, 500)
            
            let uniqueMovies = _movies.filter { movie in
                !movies.contains(where: { $0.id == movie.id })
            }
            
            let randomizedMovies = uniqueMovies.shuffled()
            
            self.movies.append(contentsOf: randomizedMovies.shuffled())
            
            if self.genres.isEmpty {
                await self.fetchGenres()
            }
            onMoviesUpdated?()
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        onLoadingStateChanged?(false)
    }
    
    func getNextMovie() async -> Movie? {
        if movieIndex >= movies.count {
            await fetchMovies()
            print(
                "fetching movies again for more. movieIndex: \(movieIndex), movies.count: \(movies.count)"
            )
        }
        
        if movieIndex >= movies.count {
            print("movies array is empty")
            return nil
        }
        
        defer { movieIndex += 1 }
        return movies[movieIndex]
    }
    
    func getMovieByName(name: String) async throws -> Movie? {
        do {
            let _movies = try await NetworkManager.shared.fetchMoviesByName(
                name: name
            )
            if _movies.count == 0 {
                print("name: \(name) not found.")
                return nil
            } else {
                return _movies[0]
            }
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        
        return nil
    }
    
    func fetchGenres() async {
        onLoadingStateChanged?(true)
        
        do {
            let genres = try await NetworkManager.shared.fetchGenres()
            self.genres = genres
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        onLoadingStateChanged?(false)
    }
    
    func fetchDetail(for id: Int) async -> MovieDetail? {
        if let cached = detailsCache[id] { return cached }
        
        onLoadingStateChanged?(true)
        defer { onLoadingStateChanged?(false) }
        
        do {
            let detail = try await NetworkManager.shared.fetchMovieDetail(id: id)
            detailsCache[id] = detail
            return detail
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        return nil
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
    
    func formatRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
    
    func formatReleaseDate(_ date: String) -> String {
        let dateFormat = date.prefix(4)
        return String(dateFormat)
    }

    // MARK: - Save Liked Movie
    func saveLikedMovie(_ movie: Movie) {
        guard authManager.isAuthenticated else {
            print("User not authenticated, skipping liked movie save")
            return
        }
        
        preferencesManager.saveLikedMovie(movie) { result in
            switch result {
            case .success:
                print("✅ Liked movie saved: \(movie.title)")
            case .failure(let error):
                print("❌ Failed to save liked movie: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Save Disliked Movie
    func saveDislikedMovie(_ movie: Movie) {
        guard authManager.isAuthenticated else {
            print("User not authenticated, skipping disliked movie save")
            return
        }
        
        preferencesManager.saveDislikedMovie(movie) { result in
            switch result {
            case .success:
                print("✅ Disliked movie saved: \(movie.title)")
            case .failure(let error):
                print("❌ Failed to save disliked movie: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Save AI Pick Movie
    func saveAIPickMovie(_ movie: Movie) {
        guard authManager.isAuthenticated else {
            print("User not authenticated, skipping AI pick save")
            return
        }
        
        preferencesManager.saveAIPickMovie(movie) { result in
            switch result {
            case .success:
                print("✅ AI Pick movie saved: \(movie.title)")
            case .failure(let error):
                print("❌ Failed to save AI pick: \(error.localizedDescription)")
            }
        }
    }
}

