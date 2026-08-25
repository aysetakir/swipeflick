import Foundation

protocol AuthenticationVMProtocol: AnyObject {
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
    func message(for error: Error, isLogin: Bool) -> String
    func createForgotPasswordVM() -> ForgotPasswordVMProtocol
}

final class AuthenticationVM: AuthenticationVMProtocol {
    private let authManager: AuthManaging
    
    init(authManager: AuthManaging) {
        self.authManager = authManager
    }
    
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authManager.login(
            email: email,
            password: password,
            completion: completion
        )
    }
    
    func register(
        name: String,
        surname: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authManager.register(
            name: name,
            surname: surname,
            email: email,
            password: password,
            completion: completion
        )
    }

    func message(for error: Error, isLogin: Bool) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain || nsError.code == 17020 { return "authErrorNetwork".translated }
        if nsError.code == 17008 { return "authErrorInvalidEmail".translated }
        if isLogin { return "authErrorInvalidCredentials".translated }
        switch nsError.code {
        case 17007: return "authErrorEmailAlreadyInUse".translated
        case 17026: return "authErrorWeakPassword".translated
        default: return "authErrorUnknown".translated
        }
    }

    func createForgotPasswordVM() -> ForgotPasswordVMProtocol {
        ForgotPasswordVM(authManager: authManager)
    }
}
