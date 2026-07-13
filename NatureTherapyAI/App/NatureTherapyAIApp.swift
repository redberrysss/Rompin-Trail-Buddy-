import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
#endif

@main
struct NatureTherapyAIApp: App {
    #if canImport(FirebaseCore)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Participant.self,
            ActivitySession.self,
            ObservationRecord.self,
            SensoryRecord.self,
            TreasureRecord.self,
            ArtworkRecord.self,
            PendingUploadTask.self
        ])
    }
}
