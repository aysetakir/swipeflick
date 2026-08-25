import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthManager: AuthManaging {
    static let shared = FirebaseAuthManager()
    private init() {}
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    var isAuthenticated: Bool {
        auth.currentUser != nil
    }
    
    var currentUserEmail: String? {
        auth.currentUser?.email
    }
    
    // MARK: - Login
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        auth.signIn(withEmail: email, password: password) { _, error in
            if let error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
    
    // MARK: - Register
    func register(
        name: String,
        surname: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            
            if let error { completion(.failure(error)); return }
            
            guard let user = result?.user else {
                let err = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "authErrorUnknown".translated])
                completion(.failure(err))
                return
            }
            
            let userData: [String: Any] = [
                "uid": user.uid,
                "name": name,
                "surname": surname,
                "email": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try auth.signOut()
            FirebaseUserPreferencesManager.shared.clearCache()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Delete Account
    func deleteAccount(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "errorNoAuthenticatedUser".translated])))
            return
        }
        user.delete { error in
            if let error { 
                completion(.failure(error)) 
            } else { 
                FirebaseUserPreferencesManager.shared.clearCache()
                completion(.success(())) 
            }
        }
    }

    // MARK: - Password Reset
    func sendPasswordReset(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
}
