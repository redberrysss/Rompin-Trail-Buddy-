import SwiftUI

struct RootView: View {
    @State private var authVM = AuthenticationViewModel()

    var body: some View {
        switch authVM.authState {
        case .loading:
            loadingView
        case .authenticated:
            mainAppView
        case .unauthenticated:
            LoginView(authVM: $authVM)
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

    private var mainAppView: some View {
        ParticipantSelectionView()
            .environment(authVM)
    }
}
