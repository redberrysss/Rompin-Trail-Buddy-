import SwiftUI
import OSLog

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
    private let logger = Logger(subsystem: "com.rompinforest.auth", category: "AuthViewModel")

    var authState: AuthState = .loading
    var currentUserID: String?
    var currentUserName: String?
    var currentUserEmail: String?

    var userRole: String = "student"
    var selectedRole: String = "student"

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
                self.clearAuthState()
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
                logger.info("Fetched role from Firestore: \(role)")
            } else {
                logger.warning("No role found in Firestore for user \(uid)")
                errorMessage = "Profil pengguna tidak dijumpai. Sila hubungi fasilitator."
                authState = .unauthenticated
            }
        } catch {
            logger.error("Failed to fetch role: \(error.localizedDescription)")
            errorMessage = "Gagal mendapatkan peranan pengguna."
            authState = .unauthenticated
        }
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

            // After sign in, wait for the auth listener to update state and fetch role
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // Validate that the fetched role matches the selected role
            guard currentUserID != nil else {
                errorMessage = "Gagal mengesahkan identiti pengguna."
                isLoading = false
                return
            }

            // Re-fetch role to ensure we have latest
            await fetchRole()

            if userRole != selectedRole {
                // Role mismatch - sign out and show error
                let correctRole = userRole == "student" ? "Peserta" : "Fasilitator"
                errorMessage = "Akaun ini didaftarkan sebagai \(correctRole). Sila pilih \(correctRole) untuk log masuk."
                try? authService.signOut()
                clearAuthState()
                authState = .unauthenticated
                isLoading = false
                return
            }

            clearForm()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
            logger.error("Sign in failed: \(error.localizedDescription)")
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

            // Wait for Firestore profile to be created and auth listener to fire
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // Verify role was saved
            if let uid = currentUserID {
                if let savedRole = try? await authService.fetchUserRole(uid: uid) {
                    userRole = savedRole
                    logger.info("Registration complete, role: \(savedRole)")
                }
            }

            clearForm()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
            logger.error("Registration failed: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func signOut() {
        errorMessage = nil
        do {
            try authService.signOut()
            clearAuthState()
            clearForm()
            logger.info("User signed out successfully")
        } catch {
            errorMessage = authService.mapFirebaseError(error)
            logger.error("Sign out failed: \(error.localizedDescription)")
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
            clearAuthState()
        } catch {
            errorMessage = authService.mapFirebaseError(error)
        }
        isLoading = false
    }

    private func clearAuthState() {
        currentUserID = nil
        currentUserName = nil
        currentUserEmail = nil
        userRole = "student"
        selectedRole = "student"
        authState = .unauthenticated
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
