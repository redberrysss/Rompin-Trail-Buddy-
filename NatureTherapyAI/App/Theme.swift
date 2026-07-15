import SwiftUI

struct AppTheme {
    // MARK: - ASD-Friendly Colours
    static let forestGreen = Color(hex: "2E7D32")
    static let emerald = Color(hex: "00B894")
    static let softBlue = Color(hex: "74B9FF")
    static let warmBeige = Color(hex: "F5E6D3")
    static let lightGreen = Color(hex: "A8E6CF")
    static let softOrange = Color(hex: "FFB347")
    static let darkGreen = Color(hex: "1B5E20")
    static let cardWhite = Color(hex: "FAFAF7")
    static let secondaryText = Color(hex: "8E8E93")
    static let dividerColor = Color(hex: "E8E8E5")
    static let softYellow = Color(hex: "FFD93D")
    static let gentleCoral = Color(hex: "FF8A80")
    static let mutedSky = Color(hex: "B8D4E3")
    static let lavender = Color(hex: "C3AED6")
    static let successGreen = Color(hex: "4CAF50")
    static let creamBackground = Color(hex: "FDFBF7")
    static let cardShadow = Color.black.opacity(0.06)
    static let cardShadowColor = Color.black.opacity(0.06)
    static let deepShadow = Color.black.opacity(0.12)

    // MARK: - Typography (Dynamic Type support)
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let subheadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 17, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .rounded)
    static let smallCaption = Font.system(size: 11, weight: .medium, design: .rounded)
    static let largeButtonFont = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let tabFont = Font.system(size: 10, weight: .medium, design: .rounded)
    static let instructionFont = Font.system(size: 20, weight: .semibold, design: .rounded)

    static let title = Font.custom("", size: 28, relativeTo: .title).weight(.bold)
    static let heading = Font.custom("", size: 22, relativeTo: .headline).weight(.semibold)
    static let body = Font.custom("", size: 17, relativeTo: .body)
    static let caption = Font.custom("", size: 13, relativeTo: .caption).weight(.medium)

    // MARK: - Layout
    static let cardCornerRadius: CGFloat = 24
    static let smallCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 20
    static let standardPadding: CGFloat = 20
    static let compactPadding: CGFloat = 16
    static let cardShadowRadius: CGFloat = 10
    static let elevatedShadowRadius: CGFloat = 20
    static let tabBarHeight: CGFloat = 80
    static let tabBarCornerRadius: CGFloat = 30

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [forestGreen, emerald],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [softOrange, Color(hex: "FF8A5C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let blueGradient = LinearGradient(
        colors: [softBlue, Color(hex: "4A90D9")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "F0F7F0"), Color(hex: "E8F5E8")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardBackground = Color(hex: "FAFAF7")
    static let glassBackground = Color(hex: "F5F5F0").opacity(0.7)

    // MARK: - Animation
    static let gentleSpring = Animation.spring(response: 0.5, dampingFraction: 0.75)
    static let smoothEase = Animation.easeInOut(duration: 0.3)
    static let fastEase = Animation.easeInOut(duration: 0.15)
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.standardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
            )
    }
}

struct PressableButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaleEffect(0.96)
            .animation(AppTheme.fastEase, value: true)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func primaryButton(color: Color = AppTheme.forestGreen) -> some View {
        self
            .font(AppTheme.largeButtonFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            )
    }

    func secondaryButton(color: Color = AppTheme.forestGreen) -> some View {
        self
            .font(AppTheme.largeButtonFont)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                    .stroke(color, lineWidth: 2)
            )
    }

    func circleButton(size: CGFloat = 60, color: Color = AppTheme.forestGreen) -> some View {
        self
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Shapes
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX, y: rect.height * 0.3),
                      control2: CGPoint(x: rect.maxX, y: rect.height * 0.7))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                      control1: CGPoint(x: rect.minX, y: rect.height * 0.7),
                      control2: CGPoint(x: rect.minX, y: rect.height * 0.3))
        return path
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Animation (backward compat)
struct AppAnimation {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let smooth = Animation.easeInOut(duration: 0.35)
    static let fast = Animation.easeInOut(duration: 0.2)
    static let slideUp = Animation.interpolatingSpring(mass: 1, stiffness: 200, damping: 25)
}

// MARK: - Reduce Motion Support
struct AccessibleAnimation {
    static func gentlePulse(for value: Bool) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? Animation.linear(duration: 0) : AppTheme.gentleSpring
    }

    static func fadeIn(for value: Bool) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? Animation.linear(duration: 0) : AppTheme.smoothEase
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
