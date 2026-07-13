import SwiftUI

struct ActivityCard: View {
    let title: String
    let emoji: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Text(emoji)
                        .font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text(description)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(AppTheme.compactPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DashboardCard<Content: View>: View {
    let title: String
    let emoji: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Text(emoji)
                        .font(.system(size: 18))
                }

                Text(title)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }

            content
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}
