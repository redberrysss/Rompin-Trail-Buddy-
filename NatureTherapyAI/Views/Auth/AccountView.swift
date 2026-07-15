import SwiftUI

struct AccountView: View {
    @Environment(AuthenticationViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false
    @State private var showPasswordReset = false
    @State private var resetEmailSent = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.lightGreen.opacity(0.3))
                                .frame(width: 72, height: 72)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.forestGreen)
                        }

                        Text(authVM.currentUserName ?? "Peserta")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)

                        Text(authVM.currentUserEmail ?? "")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    VStack(spacing: 0) {
                        AccountButton(
                            icon: "arrow.right.square",
                            title: "Log Keluar",
                            color: .orange,
                            action: { showLogoutConfirmation = true }
                        )

                        Divider().padding(.leading, 50)

                        AccountButton(
                            icon: "lock.rotation",
                            title: "Tukar Kata Laluan",
                            color: AppTheme.forestGreen,
                            action: { showPasswordReset = true }
                        )
                        .alert("E-mel Set Semula", isPresented: $showPasswordReset) {
                            Button("Hantar") {
                                Task {
                                    await authVM.resetPassword()
                                    resetEmailSent = true
                                }
                            }
                            Button("Batal", role: .cancel) {}
                        } message: {
                            Text("Hantar pautan set semula kata laluan ke \(authVM.currentUserEmail ?? "")?")
                        }

                        Divider().padding(.leading, 50)

                        AccountButton(
                            icon: "trash.circle",
                            title: "Padam Akaun",
                            color: .red,
                            action: { showDeleteConfirmation = true }
                        )
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.cardBackground)
                            .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)

                    if resetEmailSent {
                        Text("E-mel set semula telah dihantar.")
                            .font(AppTheme.captionFont)
                            .foregroundColor(.green)
                    }

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(AppTheme.captionFont)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
            .alert("Log Keluar", isPresented: $showLogoutConfirmation) {
                Button("Log Keluar", role: .destructive) {
                    authVM.signOut()
                    dismiss()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Anda akan log keluar dari aplikasi.")
            }
            .alert("Padam Akaun", isPresented: $showDeleteConfirmation) {
                Button("Padam", role: .destructive) {
                    Task { await authVM.deleteAccount() }
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Semua data akan dipadamkan secara kekal. Tindakan ini tidak boleh dibatalkan.")
            }
        }
    }
}

struct AccountButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
