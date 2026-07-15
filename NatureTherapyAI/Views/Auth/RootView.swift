import SwiftUI

struct RootView: View {
    @State private var authVM = AuthenticationViewModel()
    @State private var selectedRole: String?

    var body: some View {
        if let role = selectedRole {
            authContent(for: role)
                .environment(authVM)
        } else {
            RoleSelectionView { role in
                selectedRole = role
            }
        }
    }

    @ViewBuilder
    private func authContent(for role: String) -> some View {
        switch authVM.authState {
        case .loading:
            loadingView
        case .authenticated:
            mainAppView(for: role)
        case .unauthenticated:
            LoginView(authVM: $authVM)
                .onChange(of: authVM.authState) { _, newState in
                    if newState == .unauthenticated {
                        selectedRole = nil
                    }
                }
        }
    }

    private var loadingView: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
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
                FacilitatorDashboardView()
            } else {
                ParticipantSelectionView()
            }
        }
        .onChange(of: authVM.authState) { _, newState in
            if newState == .unauthenticated {
                selectedRole = nil
            }
        }
    }
}
