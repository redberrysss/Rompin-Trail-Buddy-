import SwiftUI

struct RegisterView: View {
    @Binding var authVM: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.forestGreen)
                        Text("Daftar Akaun Baru")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)
                    }

                    VStack(spacing: 14) {
                        FormField(label: "Nama Penuh", text: $authVM.fullName, placeholder: "Masukkan nama penuh")

                        FormField(label: "E-mel", text: $authVM.email, placeholder: "Masukkan e-mel", keyboardType: .emailAddress)

                        SecureFormField(label: "Kata Laluan", text: $authVM.password, placeholder: "Sekurang-kurangnya 6 aksara")

                        SecureFormField(label: "Pengesahan Kata Laluan", text: $authVM.confirmPassword, placeholder: "Taip semula kata laluan")

                        rolePicker

                        if let error = authVM.errorMessage {
                            Text(error)
                                .font(AppTheme.captionFont)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $authVM.agreeToPrivacy) {
                                Text("Saya memahami dan bersetuju dengan penyimpanan data aktiviti.")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.darkGreen)
                            }
                            .tint(AppTheme.forestGreen)

                            Text("Data yang disimpan termasuk butiran akaun, nama peserta, kemajuan aktiviti, gambar yang diambil, rakaman audio, dan hasil seni.")
                                .font(AppTheme.smallCaption)
                                .foregroundColor(AppTheme.secondaryText)
                                .lineSpacing(2)
                        }

                        LargeActionButton(
                            title: authVM.isLoading ? "Mendaftar..." : "Daftar",
                            icon: "person.fill.checkmark",
                            action: {
                                Task { await authVM.register() }
                            }
                        )
                        .disabled(authVM.isLoading)
                    }
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

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Jenis Akaun").font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
            HStack(spacing: 12) {
                roleButton(role: "participant", label: "Peserta", icon: "person.fill")
                roleButton(role: "facilitator", label: "Fasilitator", icon: "person.2.fill")
            }
        }
    }

    private func roleButton(role: String, label: String, icon: String) -> some View {
        Button {
            authVM.selectedRole = role
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(AppTheme.bodyFont)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(authVM.selectedRole == role ? AppTheme.forestGreen : AppTheme.cardBackground)
            .foregroundColor(authVM.selectedRole == role ? .white : AppTheme.darkGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(authVM.selectedRole == role ? AppTheme.forestGreen : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SecureFormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(AppTheme.captionFont).foregroundColor(AppTheme.darkGreen)
            SecureField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
