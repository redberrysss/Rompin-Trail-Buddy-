import SwiftUI

struct BadgeView: View {
    let badge: Badge
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.softOrange, AppTheme.emerald],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: AppTheme.softOrange.opacity(0.3), radius: 6, x: 0, y: 3)

                Text(badge.emoji)
                    .font(.system(size: 26))
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(AppAnimation.spring) {
                    scale = 1
                }
            }

            Text(badge.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.darkGreen)
                .multilineTextAlignment(.center)

            Text(badge.description)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100)
    }
}

struct BadgeGridView: View {
    let earnedBadges: [Badge]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "medal.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.softOrange)

                Text("Achievement Badges")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }

            if earnedBadges.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "star")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.lightGreen)

                        Text("No badges yet")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)

                        Text("Explore nature to earn badges!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100, maximum: 120))
                ], spacing: 16) {
                    ForEach(earnedBadges) { badge in
                        BadgeView(badge: badge)
                    }
                }
            }
        }
    }
}
