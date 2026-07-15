import SwiftUI
import SwiftData

struct RootView: View {
    @State private var authVM = AuthenticationViewModel()
    @State private var selectedRole: String?

    var body: some View {
        Group {
            if let role = selectedRole {
                authContent(for: role)
                    .environment(authVM)
            } else {
                RoleSelectionView { role in
                    selectedRole = role
                    authVM.selectedRole = role
                }
            }
        }
        .onChange(of: authVM.authState) { _, newState in
            if newState == .unauthenticated {
                selectedRole = nil
            }
        }
    }

    @ViewBuilder
    private func authContent(for role: String) -> some View {
        switch authVM.authState {
        case .loading:
            loadingView
        case .authenticated:
            if authVM.userRole == role {
                mainAppView(for: role)
            } else {
                loadingView
                    .onAppear {
                        // Wait for role to be fetched
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            if authVM.userRole != role {
                                authVM.errorMessage = "Peranan tidak sepadan. Sila cuba lagi."
                                authVM.signOut()
                            }
                        }
                    }
            }
        case .unauthenticated:
            LoginView(authVM: $authVM)
        }
    }

    private var loadingView: some View {
        ZStack {
            AppTheme.creamBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppTheme.forestGreen)
                Text("Memuatkan...")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.darkGreen)
            }
        }
    }

    @ViewBuilder
    private func mainAppView(for role: String) -> some View {
        Group {
            if role == "facilitator" {
                MainTabView(participantID: nil, participantName: nil)
            } else {
                MainTabView(participantID: UUID(), participantName: authVM.currentUserName ?? "Peserta")
            }
        }
    }
}
