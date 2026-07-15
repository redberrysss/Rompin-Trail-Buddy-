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
    private var isSigningIn = false

    init() {
        #if canImport(FirebaseAuth)
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if let user {
                let wasLoading = self.authState == .loading
                self.currentUserID = user.uid
                self.currentUserName = user.displayName
                self.currentUserEmail = user.email

                if wasLoading {
                    // App launch with existing session
                    Task {
                        await self.fetchRole()
                        if self.authState == .loading {
                            self.authState = .authenticated
                        }
                    }
                }
                // During signIn/register, authState is set manually after validation
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
        isSigningIn = true

        do {
            try await authService.signIn(email: email, password: password)

            // Wait for auth listener to populate currentUserID
            var waited = 0
            while currentUserID == nil && waited < 20 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                waited += 1
            }

            guard currentUserID != nil else {
                errorMessage = "Gagal mengesahkan identiti pengguna."
                isLoading = false
                isSigningIn = false
                authState = .unauthenticated
                return
            }

            // Fetch role from Firestore
            await fetchRole()

            guard userRole == selectedRole else {
                let correctRole = userRole == "student" ? "Peserta" : "Fasilitator"
                errorMessage = "Akaun ini didaftarkan sebagai \(correctRole). Sila pilih \(correctRole) untuk log masuk."
                try? authService.signOut()
                clearAuthState()
                isLoading = false
                isSigningIn = false
                return
            }

            // All validation passed - now set authenticated
            clearForm()
            authState = .authenticated
        } catch {
            errorMessage = authService.mapFirebaseError(error)
            logger.error("Sign in failed: \(error.localizedDescription)")
            authState = .unauthenticated
        }
        isLoading = false
        isSigningIn = false
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
        isSigningIn = true

        do {
            try await authService.register(fullName: fullName, email: email, password: password, role: selectedRole)

            // Wait for auth listener to populate currentUserID
            var waited = 0
            while currentUserID == nil && waited < 20 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                waited += 1
            }

            // Wait a bit more for Firestore profile to propagate
            try? await Task.sleep(nanoseconds: 500_000_000)

            // Verify role was saved
            if let uid = currentUserID {
                if let savedRole = try? await authService.fetchUserRole(uid: uid) {
                    userRole = savedRole
                    logger.info("Registration complete, role: \(savedRole)")
                }
            }

            clearForm()
            // Set authenticated after successful registration
            if currentUserID != nil {
                authState = .authenticated
            }
        } catch {
            errorMessage = authService.mapFirebaseError(error)
            logger.error("Registration failed: \(error.localizedDescription)")
        }
        isLoading = false
        isSigningIn = false
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
