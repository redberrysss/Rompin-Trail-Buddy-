import Foundation
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var progress: ChildProgress?
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProgress()
    }
    
    func loadProgress() {
        guard let context = modelContext else { return }
        progress = ProgressService.shared.getProgress(modelContext: context)
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning!"
        case 12..<17: return "Good Afternoon!"
        case 17..<22: return "Good Evening!"
        default: return "Hello!"
        }
    }
}
