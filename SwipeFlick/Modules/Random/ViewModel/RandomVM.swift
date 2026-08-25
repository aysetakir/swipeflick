import Foundation

protocol RandomVMProtocol {
    var selectedMood: Mood? { get }
    var randomMovie: Movie? { get }
    var isLoading: Bool { get }
    
    var onMoodSelected: (() -> Void)? { get set }
    var onMovieFound: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func selectMood(_ mood: Mood)
    func fetchRandomMovie() async
    func reset()
}

@MainActor
final class RandomVM: RandomVMProtocol {
    
    // MARK: - Properties
    private(set) var selectedMood: Mood?
    private(set) var randomMovie: Movie?
    private(set) var isLoading: Bool = false
    private(set) var randomMovieMaxPage = 5
    
    // MARK: - Callbacks
    var onMoodSelected: (() -> Void)?
    var onMovieFound: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    // MARK: - Methods
    func selectMood(_ mood: Mood) {
        self.selectedMood = mood
        onMoodSelected?()
        
        Task {
            await fetchRandomMovie()
        }
    }
    
    func fetchRandomMovie() async {
        guard let mood = selectedMood else {
            onError?("mood_not_selected".translated)
            return
        }
        
        isLoading = true
        onLoadingStateChanged?(true)
        
        do {
            let (_, totalPages) = try await NetworkManager.shared
                .fetchRandomMovieByMoods(genreIDs: mood.genreIDs, page: 1)
             
            let safePage = Int.random(in: 1...min(totalPages, 500))
             
            let (movies, _) = try await NetworkManager.shared
                .fetchRandomMovieByMoods(genreIDs: mood.genreIDs, page: safePage)
            
            if let randomMovie = movies.randomElement() {
                self.randomMovie = randomMovie
                onMovieFound?()
            } else {
                onError?("no_movies_found".translated)
            }
            
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            onError?(error.localizedDescription)
        }
        
        isLoading = false
        onLoadingStateChanged?(false)
    }
    
    func reset() {
        selectedMood = nil
        randomMovie = nil
        isLoading = false
    }
    
    // MARK: - Private Methods
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
