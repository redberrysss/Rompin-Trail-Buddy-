import SwiftUI

struct VisualInstructionCard: View {
    let emoji: String
    let title: String
    let description: String
    var stepLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let step = stepLabel {
                Text(step)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.lightGreen.opacity(0.3))
                    )
            }

            HStack(alignment: .top, spacing: 16) {
                Text(emoji)
                    .font(.system(size: 52))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.darkGreen)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(description)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.warmBeige, AppTheme.lightGreen.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.lightGreen.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
}

#Preview {
    VStack(spacing: 16) {
        VisualInstructionCard(
            emoji: "🌿",
            title: "Tarik Nafas",
            description: "Tarik nafas perlahan-lahan dan hirup udara segar hutan.",
            stepLabel: "Langkah 1 daripada 4"
        )

        VisualInstructionCard(
            emoji: "👀",
            title: "Perhatikan Sekeliling",
            description: "Lihat pokok-pokok di sekitar anda. Apa yang anda nampak?"
        )
    }
    .padding()
    .background(AppTheme.backgroundGradient)
}
