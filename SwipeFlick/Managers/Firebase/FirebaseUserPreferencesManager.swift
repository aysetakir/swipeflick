import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseUserPreferencesManager: UserPreferencesManaging {
    static let shared = FirebaseUserPreferencesManager()
    private init() {}

    private let db = Firestore.firestore()
    private var likedListener: ListenerRegistration?
    private var dislikedListener: ListenerRegistration?
    private var aiPicksListener: ListenerRegistration?
    
    // Cache
    private var cachedLikedMovies: [Movie]?
    private var cachedDislikedMovies: [Movie]?
    private var cachedAIPickMovies: [Movie]?

    // MARK: - AI Preferences
    func fetchAIPreferences(completion: @escaping (Result<String?, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success(nil))
            return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error { completion(.failure(error)); return }
            let value = snapshot?.data()?["aiPreferences"] as? String
            completion(.success(value))
        }
    }

    func saveAIPreferences(text: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserPrefs", code: -1, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        let doc = db.collection("users").document(uid)
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            doc.setData(["aiPreferences": FieldValue.delete()], merge: true) { error in
                if let error { completion(.failure(error)) } else { completion(.success(())) }
            }
        } else {
            doc.setData(["aiPreferences": trimmed], merge: true) { error in
                if let error { completion(.failure(error)) } else { completion(.success(())) }
            }
        }
    }
    
    // MARK: - Liked Movies Management
    func saveLikedMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserPrefs", code: -1, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        
        let movieData = movie.toDictionary()
        let movieRef = db.collection("users").document(uid).collection("likedMovies").document("\(movie.id)")
        
        movieRef.setData(movieData) { [weak self] error in
            if let error {
                completion(.failure(error))
            } else {
                self?.cachedLikedMovies?.insert(movie, at: 0)
                completion(.success(()))
            }
        }
    }
    
    func fetchLikedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }
        
        if let cached = cachedLikedMovies {
            completion(.success(cached))
            return
        }
        
        db.collection("users").document(uid).collection("likedMovies")
            .getDocuments { [weak self] snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                let movies = snapshot?.documents.compactMap { doc -> Movie? in
                    Movie(from: doc.data())
                } ?? []
                let sortedMovies = movies.sorted { $0.id > $1.id }
                
                self?.cachedLikedMovies = sortedMovies
                completion(.success(sortedMovies))
            }
    }
    
    func removeLikedMovie(movieId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserPrefs", code: -1, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        
        db.collection("users").document(uid).collection("likedMovies").document("\(movieId)").delete { [weak self] error in
            if let error {
                completion(.failure(error))
            } else {
                self?.cachedLikedMovies?.removeAll { $0.id == movieId }
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Disliked Movies Management
    func saveDislikedMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserPrefs", code: -1, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        
        let movieData = movie.toDictionary()
        let movieRef = db.collection("users").document(uid).collection("dislikedMovies").document("\(movie.id)")
        
        movieRef.setData(movieData) { [weak self] error in
            if let error {
                completion(.failure(error))
            } else {
                self?.cachedDislikedMovies?.insert(movie, at: 0)
                completion(.success(()))
            }
        }
    }
    
    func fetchDislikedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }
        
        if let cached = cachedDislikedMovies {
            completion(.success(cached))
            return
        }
        
        db.collection("users").document(uid).collection("dislikedMovies")
            .getDocuments { [weak self] snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                let movies = snapshot?.documents.compactMap { doc -> Movie? in
                    Movie(from: doc.data())
                } ?? []
                let sortedMovies = movies.sorted { $0.id > $1.id }
                
                self?.cachedDislikedMovies = sortedMovies
                completion(.success(sortedMovies))
            }
    }
    
    // MARK: - AI Picks Management
    func saveAIPickMovie(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserPrefs", code: -1, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        
        let movieData = movie.toDictionary()
        let movieRef = db.collection("users").document(uid).collection("aiPicks").document("\(movie.id)")
        
        movieRef.setData(movieData) { [weak self] error in
            if let error {
                completion(.failure(error))
            } else {
                self?.cachedAIPickMovies?.insert(movie, at: 0)
                completion(.success(()))
            }
        }
    }
    
    func fetchAIPickMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }
        
        if let cached = cachedAIPickMovies {
            completion(.success(cached))
            return
        }
        
        db.collection("users").document(uid).collection("aiPicks")
            .getDocuments { [weak self] snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                let movies = snapshot?.documents.compactMap { doc -> Movie? in
                    Movie(from: doc.data())
                } ?? []
                let sortedMovies = movies.sorted { $0.id > $1.id }
                
                self?.cachedAIPickMovies = sortedMovies
                completion(.success(sortedMovies))
            }
    }
    
    // MARK: - Realtime Stats Listening
    func observeStats(completion: @escaping (Int, Int, Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var likedCount = 0
        var dislikedCount = 0
        var aiPicksCount = 0
        likedListener = db.collection("users").document(uid).collection("likedMovies")
            .addSnapshotListener { snapshot, error in
                if error == nil {
                    likedCount = snapshot?.documents.count ?? 0
                    completion(likedCount, dislikedCount, aiPicksCount)
                }
            }
        dislikedListener = db.collection("users").document(uid).collection("dislikedMovies")
            .addSnapshotListener { snapshot, error in
                if error == nil {
                    dislikedCount = snapshot?.documents.count ?? 0
                    completion(likedCount, dislikedCount, aiPicksCount)
                }
            }
        aiPicksListener = db.collection("users").document(uid).collection("aiPicks")
            .addSnapshotListener { snapshot, error in
                if error == nil {
                    aiPicksCount = snapshot?.documents.count ?? 0
                    completion(likedCount, dislikedCount, aiPicksCount)
                }
            }
    }
    
    func stopObservingStats() {
        likedListener?.remove()
        dislikedListener?.remove()
        aiPicksListener?.remove()
        likedListener = nil
        dislikedListener = nil
        aiPicksListener = nil
    }
    
    // MARK: - Cache Management
    func prefetchAllData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        fetchLikedMovies { _ in group.leave() }
        
        group.enter()
        fetchDislikedMovies { _ in group.leave() }
        
        group.enter()
        fetchAIPickMovies { _ in group.leave() }
        
        group.notify(queue: .main) { completion() }
    }
    
    func clearCache() {
        cachedLikedMovies = nil
        cachedDislikedMovies = nil
        cachedAIPickMovies = nil
    }
}
