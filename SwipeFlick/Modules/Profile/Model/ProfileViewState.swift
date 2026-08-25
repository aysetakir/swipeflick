import Foundation

struct ProfileViewState {
    let isAuthenticated: Bool
    let email: String?
    let displayName: String?
    let bio: String?
    let stats: ProfileStats
    let savedMovies: [Movie]
    let aiRecommendations: [Movie]
}
