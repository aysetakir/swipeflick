import Foundation

protocol AuthManaging {
    var isAuthenticated: Bool { get }
    var currentUserEmail: String? { get }
    
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func register(
        name: String,
        surname: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func logout(
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func deleteAccount(
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func sendPasswordReset(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
