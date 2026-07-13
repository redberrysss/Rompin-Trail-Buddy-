import SwiftUI

struct LoginView: View {
    @Binding var authVM: AuthenticationViewModel

    @State private var showRegister = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.forestGreen)

                        Text("Rompin Forest Explorer")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)

                        Text("Log Masuk")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("E-mel").font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
                            TextField("Masukkan e-mel", text: $authVM.email)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Kata Laluan").font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
                            SecureField("Masukkan kata laluan", text: $authVM.password)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if let error = authVM.errorMessage {
                            Text(error)
                                .font(AppTheme.captionFont)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        LargeActionButton(
                            title: authVM.isLoading ? "Memuat naik..." : "Log Masuk",
                            icon: "arrow.right",
                            action: {
                                Task { await authVM.signIn() }
                            }
                        )
                        .disabled(authVM.isLoading)
                    }

                    Button("Lupa Kata Laluan?") {
                        showForgotPassword = true
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.forestGreen)

                    Divider().padding(.vertical, 8)

                    Button("Daftar Akaun Baru") {
                        showRegister = true
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.forestGreen)
                }
                .padding(.horizontal, 24)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .sheet(isPresented: $showRegister) {
                RegisterView(authVM: $authVM)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(authVM: $authVM)
            }
        }
    }
}
