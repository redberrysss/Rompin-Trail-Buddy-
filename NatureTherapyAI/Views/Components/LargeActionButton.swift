import SwiftUI

struct LargeActionButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = AppTheme.forestGreen
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                }

                Text(title)
                    .font(AppTheme.titleFont)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)
            .padding(.vertical, 16)
            .padding(.horizontal, AppTheme.standardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                    .fill(
                        isDisabled
                            ? AnyShapeStyle(color.opacity(0.4))
                            : AnyShapeStyle(color)
                    )
                    .shadow(
                        color: isDisabled ? .clear : color.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .accessibilityLabel(title)
        .accessibilityHint(isDisabled ? "Butang tidak aktif" : "Taip untuk meneruskan")
    }
}

#Preview {
    VStack(spacing: 16) {
        LargeActionButton(title: "Mula Aktiviti", icon: "play.fill") {}

        LargeActionButton(
            title: "Seterusnya",
            icon: "arrow.right",
            color: AppTheme.emerald
        ) {}

        LargeActionButton(
            title: "Tidak Aktif",
            icon: "lock.fill",
            isDisabled: true
        ) {}
    }
    .padding()
    .background(AppTheme.backgroundGradient)
}
