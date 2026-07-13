import SwiftUI

struct ProgressHeader: View {
    let current: Int
    let total: Int
    var showPercentage: Bool = false

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }

    private var percentageText: String {
        "\(Int(progress * 100))%"
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(current) daripada \(total) selesai")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()

                if showPercentage {
                    Text(percentageText)
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geo.size.width * progress, height: 12)
                        .animation(.easeInOut(duration: 0.4), value: current)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, AppTheme.compactPadding)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progres: \(current) daripada \(total) selesai. \(showPercentage ? percentageText : "")")
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressHeader(current: 2, total: 5)
        ProgressHeader(current: 4, total: 5, showPercentage: true)
        ProgressHeader(current: 5, total: 5, showPercentage: true)
    }
    .padding()
    .background(AppTheme.backgroundGradient)
}
