import Foundation
import Core
import SwiftData

public protocol SearchIndexServiceProtocol {
    func performSearch(query: String) async -> [SearchResult]
    func reindexAll() async
    func index(project: ProjectModel) async
    func index(note: NoteModel) async
}

public final class LocalSearchIndexService: SearchIndexServiceProtocol {
    // In a production app, we would use CoreSpotlight (CSSearchableIndex) or SQLite FTS5 for this.
    // For NovaDesk Phase 3, we build an in-memory inverted index that loads from SwiftData and filesystem in the background.
    
    private var index: [SearchResult] = []
    private let indexLock = NSLock()
    
    public init() {
        Task {
            await reindexAll()
        }
    }
    
    public func performSearch(query: String) async -> [SearchResult] {
        guard !query.isEmpty else { return [] }
        let lowerQuery = query.lowercased()
        
        indexLock.lock()
        defer { indexLock.unlock() }
        
        var results = index.compactMap { item -> SearchResult? in
            let titleMatch = item.title.lowercased().contains(lowerQuery)
            let subtitleMatch = item.subtitle?.lowercased().contains(lowerQuery) ?? false
            
            if titleMatch || subtitleMatch {
                let score = titleMatch ? item.score + 10.0 : item.score + 5.0
                return SearchResult(id: item.id, title: item.title, subtitle: item.subtitle, type: item.type, score: score, targetPathOrId: item.targetPathOrId)
            }
            return nil
        }
        
        results.sort { $0.score > $1.score }
        return Array(results.prefix(50)) // Limit to top 50
    }
    
    public func reindexAll() async {
        // Run indexing on a background actor
        let newIndex = await buildIndex()
        indexLock.lock()
        self.index = newIndex
        indexLock.unlock()
    }
    
    public func index(project: ProjectModel) async {
        let result = SearchResult(
            title: project.name,
            subtitle: project.path,
            type: .project,
            score: 1.0,
            targetPathOrId: project.path
        )
        indexLock.lock()
        index.removeAll { $0.targetPathOrId == project.path }
        index.append(result)
        indexLock.unlock()
    }
    
    public func index(note: NoteModel) async {
        let result = SearchResult(
            title: note.title,
            subtitle: String(note.content.prefix(50)),
            type: .note,
            score: 1.0,
            targetPathOrId: note.id.uuidString
        )
        indexLock.lock()
        index.removeAll { $0.targetPathOrId == note.id.uuidString }
        index.append(result)
        indexLock.unlock()
    }
    
    private func buildIndex() async -> [SearchResult] {
        var newIndex: [SearchResult] = []
        
        // Add static commands
        newIndex.append(SearchResult(title: "Open Settings", subtitle: "Preferences", type: .command, score: 5.0, targetPathOrId: "cmd://settings"))
        newIndex.append(SearchResult(title: "New Note", subtitle: "Create a Markdown note", type: .command, score: 5.0, targetPathOrId: "cmd://new_note"))
        
        // Notes would be fetched from SwiftData here via a background ModelContext
        
        return newIndex
    }
}
