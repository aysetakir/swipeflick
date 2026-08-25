import Foundation

protocol UserPreferencesManaging {
    func fetchAIPreferences(completion: @escaping (Result<String?, Error>) -> Void)
    func saveAIPreferences(text: String?, completion: @escaping (Result<Void, Error>) -> Void)
    
    // MARK: - Liked Movies Management
    func saveLikedMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchLikedMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
    func removeLikedMovie(movieId: Int, completion: @escaping (Result<Void, Error>) -> Void)
    
    // MARK: - Disliked Movies Management
    func saveDislikedMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchDislikedMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
    
    // MARK: - AI Picks Management
    func saveAIPickMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchAIPickMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
    
    // MARK: - Realtime Stats Listening
    
    // MARK: - Cache Management
    func prefetchAllData(completion: @escaping () -> Void)
    func clearCache()
}
