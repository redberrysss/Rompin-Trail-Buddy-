import SwiftUI

struct ForgotPasswordView: View {
    @Binding var authVM: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 30)

                    VStack(spacing: 8) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.forestGreen)
                        Text("Set Semula Kata Laluan")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)
                        Text("Masukkan e-mel anda. Kami akan hantar pautan set semula.")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("E-mel").font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
                        TextField("Masukkan e-mel", text: $authVM.email)
                            .textFieldStyle(.plain)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(AppTheme.captionFont)
                            .foregroundColor(error.contains("dihantar") ? .green : .red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    LargeActionButton(
                        title: authVM.isLoading ? "Menghantar..." : "Hantar Pautan Set Semula",
                        icon: "paperplane.fill",
                        action: {
                            Task { await authVM.resetPassword() }
                        }
                    )
                    .disabled(authVM.isLoading)
                }
                .padding(.horizontal, 24)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }
}
