import SwiftUI
import Core
import UIComponents
// import NovaModules // Will be used when we integrate concrete feature views

@main
struct NovaDeskApp: App {
    // Shared Persistence layer
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainSplitView()
                .environment(\.modelContext, persistenceController.mainContext)
                .withThemeEngine()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
            // Add custom global commands here later (e.g., Global Search ⌘K)
        }
    }
}
