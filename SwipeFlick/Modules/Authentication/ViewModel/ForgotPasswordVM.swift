import Foundation

protocol ForgotPasswordVMProtocol: AnyObject {
    func sendReset(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func message(for error: Error) -> String
}

final class ForgotPasswordVM: ForgotPasswordVMProtocol {
    private let authManager: AuthManaging
    
    init(authManager: AuthManaging) {
        self.authManager = authManager
    }
    
    func sendReset(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authManager.sendPasswordReset(email: email, completion: completion)
    }
    
    func message(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain || nsError.code == 17020 { return "authErrorNetwork".translated }
        if nsError.code == 17008 { return "authErrorInvalidEmail".translated }
        return "authErrorUnknown".translated
    }
}
