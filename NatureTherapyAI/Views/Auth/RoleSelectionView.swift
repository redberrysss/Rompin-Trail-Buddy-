import SwiftUI

struct RoleSelectionView: View {
    let onSelectRole: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Rompin Forest Explorer")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Siapa anda?")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.bottom, 48)

            VStack(spacing: 20) {
                Button {
                    onSelectRole("facilitator")
                } label: {
                    roleCard(
                        icon: "person.fill.gearshape",
                        title: "Fasilitator",
                        subtitle: "Urus peserta dan lihat kemajuan",
                        color: AppTheme.forestGreen,
                        gradient: AppTheme.primaryGradient
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    onSelectRole("peserta")
                } label: {
                    roleCard(
                        icon: "person.fill",
                        title: "Peserta",
                        subtitle: "Teroka alam dan lengkapkan aktiviti",
                        color: AppTheme.softBlue,
                        gradient: AppTheme.blueGradient
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
    }

    private func roleCard(icon: String, title: String, subtitle: String, color: Color, gradient: LinearGradient) -> some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient)
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }
}
