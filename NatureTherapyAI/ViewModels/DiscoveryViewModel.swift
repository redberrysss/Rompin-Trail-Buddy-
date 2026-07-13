import Foundation
import SwiftData
import SwiftUI

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var natureObject: NatureObject?
    @Published var allDiscoveredObjects: [NatureObject] = []
    @Published var showFact = false
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDiscoveredObjects()
    }
    
    func loadDiscoveredObjects() {
        guard let context = modelContext else { return }
        allDiscoveredObjects = ProgressService.shared.getAllDiscoveredObjects(modelContext: context)
    }
    
    func toggleFact() {
        withAnimation {
            showFact.toggle()
        }
    }
}
