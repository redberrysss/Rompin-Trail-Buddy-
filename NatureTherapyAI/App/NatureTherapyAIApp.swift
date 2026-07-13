import SwiftUI
import SwiftData

@main
struct NatureTherapyAIApp: App {
    var body: some Scene {
        WindowGroup {
            ParticipantSelectionView()
        }
        .modelContainer(for: [
            Participant.self,
            ActivitySession.self,
            ObservationRecord.self,
            SensoryRecord.self,
            TreasureRecord.self,
            ArtworkRecord.self
        ])
    }
}
