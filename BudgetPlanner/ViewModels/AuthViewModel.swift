import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import LocalAuthentication


class AuthViewModel: ObservableObject {
    @Published var user: AppUser?

    private var db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    func listenToAuthState() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            guard let user = user else {
                self.user = nil
                return
            }
            self.fetchUser(uid: user.uid)
        }
    }

    func register(email: String, password: String, username: String, mobile: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                completion("Registration failed.")
                return
            }

            let newUser = AppUser(id: user.uid, username: username, mobile: mobile, email: email)
            do {
                try self.db.collection("users").document(user.uid).setData(from: newUser)
                self.user = newUser
                completion(nil)
            } catch {
                completion("Failed to save user data.")
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                completion("Login failed.")
                return
            }

            self.fetchUser(uid: user.uid)
            completion(nil)
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
    }

    private func fetchUser(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = try? snapshot?.data(as: AppUser.self) else {
                print("Failed to decode user")
                return
            }
            self.user = data
        }
    }
    
    func biometricLogin(completion: @escaping (String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if biometrics are available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in with Face ID / Touch ID"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        // Proceed with login using saved credentials or restore user session
                        if let currentUser = Auth.auth().currentUser {
                            self.fetchUser(uid: currentUser.uid)
                            completion(nil)
                        } else {
                            completion("No user session available.")
                        }
                    } else {
                        completion(authError?.localizedDescription ?? "Authentication failed.")
                    }
                }
            }
        } else {
            completion("Biometric authentication not available.")
        }
    }

}
