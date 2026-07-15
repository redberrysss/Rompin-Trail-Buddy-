import SwiftUI

struct RegisterView: View {
    @Binding var authVM: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)

                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.forestGreen)

                        Text("Daftar Akaun Baru")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)

                        Text("Sila isi maklumat di bawah")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    VStack(spacing: 16) {
                        FormField(label: "Nama Penuh", text: $authVM.fullName, placeholder: "Masukkan nama penuh", icon: "person.fill")

                        FormField(label: "E-mel", text: $authVM.email, placeholder: "Masukkan e-mel", icon: "envelope.fill", keyboardType: .emailAddress)

                        SecureFormField(label: "Kata Laluan", text: $authVM.password, placeholder: "Sekurang-kurangnya 6 aksara", showPassword: $showPassword)

                        SecureFormField(label: "Pengesahan Kata Laluan", text: $authVM.confirmPassword, placeholder: "Taip semula kata laluan", showPassword: $showConfirmPassword)

                        // Role picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pilih Peranan")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.darkGreen)

                            HStack(spacing: 12) {
                                roleButton(role: "student", title: "Peserta", icon: "person.fill", color: AppTheme.softBlue)
                                roleButton(role: "facilitator", title: "Fasilitator", icon: "person.fill.gearshape", color: AppTheme.forestGreen)
                            }
                        }

                        // Privacy toggle
                        Toggle(isOn: $authVM.agreeToPrivacy) {
                            Text("Saya bersetuju dengan penyimpanan data aktiviti")
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
                        }

                        PrimaryButton(
                            title: authVM.isLoading ? "Mendaftar..." : "Daftar",
                            icon: authVM.isLoading ? nil : "person.badge.plus"
                        ) {
                            Task { await authVM.register() }
                        }
                        .disabled(authVM.isLoading)
                        .opacity(authVM.isLoading ? 0.6 : 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }

    private func roleButton(role: String, title: String, icon: String, color: Color) -> some View {
        Button {
            authVM.selectedRole = role
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(AppTheme.bodyFont)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(authVM.selectedRole == role ? color : AppTheme.cardBackground)
            )
            .foregroundColor(authVM.selectedRole == role ? .white : AppTheme.darkGreen)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(authVM.selectedRole == role ? color : AppTheme.dividerColor, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(title)
        .accessibilityAddTraits(authVM.selectedRole == role ? .isSelected : [])
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.darkGreen)
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(AppTheme.secondaryText)
                        .frame(width: 20)
                }
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.dividerColor, lineWidth: 1)
            )
            .accessibilityLabel(label)
        }
    }
}

struct SecureFormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    @Binding var showPassword: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.darkGreen)
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 20)
                if showPassword {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                } else {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                }
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppTheme.secondaryText)
                }
                .accessibilityLabel(showPassword ? "Sembunyikan" : "Tunjukkan")
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.dividerColor, lineWidth: 1)
            )
            .accessibilityLabel(label)
        }
    }
}
