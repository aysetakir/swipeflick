import Foundation

protocol ProfileVMProtocol: AnyObject {
    var onStateChange: ((ProfileViewState) -> Void)? { get set }
    var onRequestAuthentication: (() -> Void)? { get set }
    func load()
    
    func handleAuthenticationAction()
    func handleLogout(completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
}

@MainActor
final class ProfileVM: ProfileVMProtocol {
    private let authManager: AuthManaging
    private let preferencesManager: UserPreferencesManaging
    
    var onStateChange: ((ProfileViewState) -> Void)?
    var onRequestAuthentication: (() -> Void)?
    
    private var currentEmail: String?
    private var currentDisplayName: String?
    private var currentBio: String?
    private var currentSavedMovies: [Movie] = []
    private var currentAIRecommendations: [Movie] = []
    
    init(authManager: AuthManaging, preferencesManager: UserPreferencesManaging? = nil) {
        self.authManager = authManager
        self.preferencesManager = preferencesManager ?? FirebaseUserPreferencesManager.shared
    }
    
    deinit {}
    
    func load() {
        guard authManager.isAuthenticated else {
            let state = ProfileViewState(
                isAuthenticated: false,
                email: nil,
                displayName: nil,
                bio: nil,
                stats: ProfileStats(liked: 0, watched: 0, aiPicks: 0),
                savedMovies: [],
                aiRecommendations: []
            )
            onStateChange?(state)
            return
        }

        Task { [weak self] in
            guard let self else { return }
            let email = authManager.currentUserEmail
            let display = email?
                .split(separator: "@").first
                .map { String($0).replacingOccurrences(of: ".", with: " ").capitalized }
            
            self.currentEmail = email
            self.currentDisplayName = display
            self.currentBio = "profileBioDefault".translated
            
            let likedMovies = await withCheckedContinuation { continuation in
                self.preferencesManager.fetchLikedMovies { result in
                    switch result {
                    case .success(let movies):
                        continuation.resume(returning: movies)
                    case .failure(let error):
                        print("❌ Error fetching liked movies: \(error.localizedDescription)")
                        continuation.resume(returning: [])
                    }
                }
            }
            
            let dislikedMovies = await withCheckedContinuation { continuation in
                self.preferencesManager.fetchDislikedMovies { result in
                    switch result {
                    case .success(let movies):
                        continuation.resume(returning: movies)
                    case .failure(let error):
                        print("❌ Error fetching disliked movies: \(error.localizedDescription)")
                        continuation.resume(returning: [])
                    }
                }
            }
            
            let aiPickMovies = await withCheckedContinuation { continuation in
                self.preferencesManager.fetchAIPickMovies { result in
                    switch result {
                    case .success(let movies):
                        continuation.resume(returning: movies)
                    case .failure(let error):
                        print("❌ Error fetching AI picks: \(error.localizedDescription)")
                        continuation.resume(returning: [])
                    }
                }
            }
            
            self.currentSavedMovies = Array(aiPickMovies.prefix(10))
            
            let aiResponse = try? await NetworkManager.shared.fetchMovies(page: 2)
            let aiMovies = aiResponse?.0 ?? []
            self.currentAIRecommendations = Array(aiMovies.prefix(6))
            
            let stats = ProfileStats(
                liked: likedMovies.count,
                watched: dislikedMovies.count,
                aiPicks: aiPickMovies.count
            )

            let state = ProfileViewState(
                isAuthenticated: true,
                email: email,
                displayName: display,
                bio: self.currentBio,
                stats: stats,
                savedMovies: self.currentSavedMovies,
                aiRecommendations: self.currentAIRecommendations
            )
            self.onStateChange?(state)
            
        }
    }
    
        
    func handleAuthenticationAction() {
        guard !authManager.isAuthenticated else { return }
        onRequestAuthentication?()
    }
    
    func handleLogout(completion: @escaping (Result<Void, Error>) -> Void) {
        authManager.logout { [weak self] result in
            if case .success = result {
                self?.load()
            }
            completion(result)
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        authManager.deleteAccount { [weak self] result in
            if case .success = result {
                self?.load()
            }
            completion(result)
        }
    }
}

