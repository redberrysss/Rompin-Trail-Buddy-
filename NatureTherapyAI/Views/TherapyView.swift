import SwiftUI
import SwiftData

struct TherapyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TherapyViewModel()
    @State private var selectedTool = "Finger"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                    breathingSection
                    drawingSection
                    challengeSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 90)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Therapy")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .overlay {
                if viewModel.showCompletionMessage {
                    completionOverlay
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 72, height: 72)

                Text("🧘")
                    .font(.system(size: 36))
            }

            Text("Therapy Activities")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Fun exercises to help you relax, focus, and explore")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .padding(.top, 8)
    }

    private var breathingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.softBlue.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "wind")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.softBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Breathing Exercise")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Follow the circle: breathe in as it grows, out as it shrinks")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            if viewModel.isBreathingActive {
                BreathingAnimation(
                    phase: $viewModel.breathingPhase,
                    onComplete: { viewModel.completeBreathing() }
                )
                .frame(height: 260)

                Button(action: viewModel.stopBreathing) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(AppTheme.largeButtonFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(Color.red)
                                .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 4)
                        )
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "circle.dotted")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.softBlue)

                    Button(action: viewModel.startBreathing) {
                        Label("Start Breathing", systemImage: "play.fill")
                            .font(AppTheme.largeButtonFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                    .fill(AppTheme.forestGreen)
                                    .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 6, x: 0, y: 4)
                            )
                    }
                }
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var drawingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.softOrange.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.softOrange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Nature Drawing")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Use your finger like a paintbrush")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }

                Spacer()
            }

            NatureDrawingCanvas(
                selectedTool: $selectedTool,
                onComplete: { viewModel.completeDrawing() }
            )
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "eye.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.emerald)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Observation Challenge")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Look closely and discover something new")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            if viewModel.challengeCompleted {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.emerald.opacity(0.15))
                            .frame(width: 64, height: 64)

                        Text("🎉")
                            .font(.system(size: 32))
                    }

                    Text("Challenge Complete!")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Great job observing nature!")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)

                    Button(action: viewModel.newChallenge) {
                        Label("New Challenge", systemImage: "arrow.clockwise")
                            .font(AppTheme.largeButtonFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                    .fill(AppTheme.forestGreen)
                                    .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 6, x: 0, y: 4)
                            )
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Text("Your Challenge")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)

                    Text(viewModel.currentChallenge)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.darkGreen)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 14) {
                        Button(action: viewModel.newChallenge) {
                            Label("Skip", systemImage: "forward.fill")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                        .fill(AppTheme.secondaryText.opacity(0.1))
                                )
                        }

                        Button(action: viewModel.completeChallenge) {
                            Label("Done!", systemImage: "checkmark.circle.fill")
                                .font(AppTheme.captionFont)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                        .fill(AppTheme.forestGreen)
                                        .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 6, x: 0, y: 4)
                                )
                        }
                    }
                }
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(width: 80, height: 80)

                    Text("🌟")
                        .font(.system(size: 40))
                }

                Text("Amazing Job!")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Keep exploring and having fun with nature!")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)

                Button(action: viewModel.dismissCompletion) {
                    Text("Continue")
                        .font(AppTheme.largeButtonFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(AppTheme.primaryGradient)
                                .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.horizontal, 20)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}
