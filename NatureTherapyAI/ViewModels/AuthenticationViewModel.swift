import SwiftUI

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

enum AuthState {
    case loading
    case authenticated
    case unauthenticated
}

@Observable
final class AuthenticationViewModel {
    private let authService = AuthenticationService.shared

    var authState: AuthState = .loading
    var currentUserID: String?
    var currentUserName: String?
    var currentUserEmail: String?

    var userRole: String = "participant"
    var selectedRole: String = "participant"

    var email = ""
    var password = ""
    var confirmPassword = ""
    var fullName = ""
    var agreeToPrivacy = false

    var isLoading = false
    var errorMessage: String?

    private var authStateHandler: Any?

    init() {
        #if canImport(FirebaseAuth)
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if let user {
                self.currentUserID = user.uid
                self.currentUserName = user.displayName
                self.currentUserEmail = user.email
                self.authState = .authenticated
                Task { await self.fetchRole() }
            } else {
                self.currentUserID = nil
                self.currentUserName = nil
                self.currentUserEmail = nil
                self.userRole = "participant"
                self.authState = .unauthenticated
            }
        }
        #else
        self.authState = .unauthenticated
        #endif
    }

    func fetchRole() async {
        guard let uid = currentUserID else { return }
        do {
            if let role = try await authService.fetchUserRole(uid: uid) {
                userRole = role
            }
        } catch {}
    }

    func signIn() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Sila masukkan e-mel."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Sila masukkan kata laluan."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
            clearForm()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
        isLoading = false
    }

    func register() async {
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Sila masukkan nama penuh."
            return
        }
        guard isValidEmail(email) else {
            errorMessage = "Alamat e-mel tidak sah."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Kata laluan mesti sekurang-kurangnya 6 aksara."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Kata laluan tidak sepadan."
            return
        }
        guard agreeToPrivacy else {
            errorMessage = "Sila setuju dengan penyimpanan data aktiviti."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            try await authService.register(fullName: fullName, email: email, password: password, role: selectedRole)
            userRole = selectedRole
            clearForm()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
            clearForm()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
    }

    func resetPassword() async {
        guard isValidEmail(email) else {
            errorMessage = "Sila masukkan alamat e-mel yang sah."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await authService.resetPassword(email: email)
            errorMessage = "E-mel set semula kata laluan telah dihantar."
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
        isLoading = false
    }

    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
        isLoading = false
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
        agreeToPrivacy = false
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    deinit {
        #if canImport(FirebaseAuth)
        if let handler = authStateHandler as? NSObjectProtocol {
            Auth.auth().removeStateDidChangeListener(handler)
        }
        #endif
    }
}
