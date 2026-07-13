import SwiftUI

struct EmotionCard: View {
    let emotion: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 44))

                Text(emotion)
                    .font(AppTheme.subheadline)
                    .foregroundColor(isSelected ? AppTheme.darkGreen : AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(isSelected ? AppTheme.lightGreen.opacity(0.25) : AppTheme.cardWhite)
                    .shadow(
                        color: isSelected
                            ? AppTheme.forestGreen.opacity(0.15)
                            : AppTheme.cardShadowColor,
                        radius: isSelected ? 10 : AppTheme.cardShadowRadius,
                        x: 0, y: isSelected ? 2 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(
                        isSelected ? AppTheme.forestGreen : AppTheme.dividerColor,
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(emotion)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

enum Emotion: String, CaseIterable, Identifiable {
    case gembira = "Gembira"
    case tenang = "Tenang"
    case tidakPasti = "Tidak Pasti"
    case tidakSelesa = "Tidak Selesa"
    case perlukanRehat = "Perlukan Rehat"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .gembira: return "😊"
        case .tenang: return "😌"
        case .tidakPasti: return "🤔"
        case .tidakSelesa: return "😰"
        case .perlukanRehat: return "😴"
        }
    }
}

#Preview {
    @Previewable @State var selected: Emotion? = nil

    VStack(spacing: 16) {
        Text("Bagaimana perasaan anda?")
            .font(AppTheme.titleFont)
            .foregroundColor(AppTheme.darkGreen)

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            ForEach(Emotion.allCases) { emotion in
                EmotionCard(
                    emotion: emotion.rawValue,
                    emoji: emotion.emoji,
                    isSelected: selected == emotion,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = emotion
                        }
                    }
                )
            }
        }
    }
    .padding()
    .background(AppTheme.backgroundGradient)
}
