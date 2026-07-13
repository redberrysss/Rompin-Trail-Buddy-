import Foundation
import SwiftData

@MainActor
final class TherapyViewModel: ObservableObject {
    @Published var selectedActivity: ActivityType?
    @Published var isBreathingActive = false
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var drawingColor: String = "green"
    @Published var currentChallenge = ""
    @Published var challengeCompleted = false
    @Published var showCompletionMessage = false
    
    private var modelContext: ModelContext?
    
    let challenges = [
        "Find 3 different types of leaves",
        "Find something smooth and something rough",
        "Find a flower and name its color",
        "Find something that makes a sound",
        "Find something that smells nice",
        "Find a pattern in nature",
        "Find something taller than you",
        "Find something smaller than your hand",
        "Find 2 things that are the same color",
        "Find a sign of an animal"
    ]
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        newChallenge()
    }
    
    func startBreathing() {
        isBreathingActive = true
        breathingPhase = .inhale
    }
    
    func stopBreathing() {
        isBreathingActive = false
        breathingPhase = .idle
    }
    
    func completeBreathing() {
        guard let context = modelContext else { return }
        ProgressService.shared.recordActivity(type: .breathing, modelContext: context)
        stopBreathing()
        showCompletionMessage = true
    }
    
    func completeDrawing() {
        guard let context = modelContext else { return }
        ProgressService.shared.recordActivity(type: .drawing, modelContext: context)
        showCompletionMessage = true
    }
    
    func completeChallenge() {
        challengeCompleted = true
        guard let context = modelContext else { return }
        ProgressService.shared.recordActivity(type: .observation, modelContext: context)
        showCompletionMessage = true
    }
    
    func newChallenge() {
        challengeCompleted = false
        currentChallenge = challenges.randomElement() ?? challenges[0]
    }
    
    func dismissCompletion() {
        showCompletionMessage = false
    }
}

enum BreathingPhase {
    case idle, inhale, hold, exhale
    
    var label: String {
        switch self {
        case .idle: return "Ready"
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .idle: return 0
        case .inhale: return 4.0
        case .hold: return 2.0
        case .exhale: return 6.0
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .idle: return 0.5
        case .inhale: return 1.0
        case .hold: return 1.0
        case .exhale: return 0.5
        }
    }
}
