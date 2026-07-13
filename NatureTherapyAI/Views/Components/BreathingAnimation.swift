import SwiftUI

struct BreathingAnimation: View {
    @Binding var phase: BreathingPhase
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.6

    var body: some View {
        VStack(spacing: 24) {
            Text(phase.label)
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
                .contentTransition(.identity)

            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.lightGreen, AppTheme.forestGreen.opacity(0.7)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200 * scale, height: 200 * scale)
                    .opacity(opacity)
                    .shadow(color: AppTheme.forestGreen.opacity(0.2), radius: 20, x: 0, y: 0)

                Circle()
                    .stroke(AppTheme.forestGreen.opacity(0.3), lineWidth: 2)
                    .frame(width: 200, height: 200)
            }
            .animation(.easeInOut(duration: phase.duration), value: phase)

            if phase != .idle {
                Text(phase == .inhale ? "🌬️" : phase == .hold ? "🤫" : "🌿")
                    .font(.system(size: 36))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear { startCycle() }
    }

    private func startCycle() {
        guard phase != .idle else { return }

        withAnimation(.easeInOut(duration: BreathingPhase.inhale.duration)) {
            phase = .inhale
            scale = 1.0
            opacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + BreathingPhase.inhale.duration) {
            withAnimation(.easeInOut(duration: BreathingPhase.hold.duration)) {
                phase = .hold
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + BreathingPhase.inhale.duration + BreathingPhase.hold.duration
        ) {
            withAnimation(.easeInOut(duration: BreathingPhase.exhale.duration)) {
                phase = .exhale
                scale = 0.5
                opacity = 0.6
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + BreathingPhase.inhale.duration + BreathingPhase.hold.duration + BreathingPhase.exhale.duration
        ) {
            onComplete()
        }
    }
}
