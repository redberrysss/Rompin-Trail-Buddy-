import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    let onConfirm: () -> Void
    let onRetake: () -> Void
    let onSkip: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Gambar")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)

            VStack(spacing: 12) {
                LargeActionButton(
                    title: "Gunakan",
                    icon: "checkmark.circle.fill",
                    color: AppTheme.forestGreen
                ) {
                    onConfirm()
                }

                LargeActionButton(
                    title: "Ambil Semula",
                    icon: "camera.fill",
                    color: AppTheme.softBlue
                ) {
                    onRetake()
                }

                if let skip = onSkip {
                    LargeActionButton(
                        title: "Langkau",
                        icon: "forward.fill",
                        color: AppTheme.secondaryText
                    ) {
                        skip()
                    }
                }
            }
            .padding(.horizontal, AppTheme.compactPadding)
        }
        .padding(AppTheme.standardPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundGradient)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    PhotoPreviewView(
        image: UIImage(),
        onConfirm: {},
        onRetake: {},
        onSkip: {}
    )
}
