import SwiftUI

struct LoginView: View {
    @Binding var authVM: AuthenticationViewModel

    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var showPassword = false
    @State private var rememberMe = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 56))
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
                            Text("E-mel")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.darkGreen)
                            TextField("Masukkan e-mel", text: $authVM.email)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.dividerColor, lineWidth: 1)
                                )
                                .accessibilityLabel("E-mel")
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Kata Laluan")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.darkGreen)
                            HStack {
                                if showPassword {
                                    TextField("Masukkan kata laluan", text: $authVM.password)
                                        .textFieldStyle(.plain)
                                } else {
                                    SecureField("Masukkan kata laluan", text: $authVM.password)
                                        .textFieldStyle(.plain)
                                }
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                                .accessibilityLabel(showPassword ? "Sembunyikan kata laluan" : "Tunjukkan kata laluan")
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.dividerColor, lineWidth: 1)
                            )
                        }

                        Toggle(isOn: $rememberMe) {
                            Text("Ingat Saya")
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        .toggleStyle(.switch)
                        .tint(AppTheme.forestGreen)

                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .accessibilityLabel(error)
                        }

                        PrimaryButton(
                            title: authVM.isLoading ? "Memuat naik..." : "Log Masuk",
                            icon: authVM.isLoading ? nil : "arrow.right"
                        ) {
                            Task { await authVM.signIn() }
                        }
                        .disabled(authVM.isLoading)
                        .opacity(authVM.isLoading ? 0.6 : 1)
                    }

                    Button("Lupa Kata Laluan?") {
                        showForgotPassword = true
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.forestGreen)

                    HStack {
                        VStack { Divider() }
                        Text("atau")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                        VStack { Divider() }
                    }

                    SecondaryButton(title: "Daftar Akaun Baru", icon: "person.badge.plus") {
                        showRegister = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .sheet(isPresented: $showRegister) {
                RegisterView(authVM: $authVM)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(authVM: $authVM)
            }
        }
    }
}
