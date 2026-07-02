import Foundation
import SwiftData

/// Manages the SwiftData container and contexts for the application.
@MainActor
public final class PersistenceController {
    public static let shared = PersistenceController()
    
    public let container: ModelContainer
    
    private init() {
        do {
            // In Phase 1, we will set up the schema progressively.
            // When we introduce concrete SwiftData models, they must be added to this array.
            let schema = Schema([
                NoteFolder.self,
                NoteModel.self,
                SnippetCategory.self,
                SnippetModel.self,
                AIConversation.self,
                AIMessage.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                // Uses a default application support URL derived by SwiftData
                cloudKitDatabase: .none
            )
            
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    public var mainContext: ModelContext {
        container.mainContext
    }
}
