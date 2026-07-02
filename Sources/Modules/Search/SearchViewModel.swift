import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class SearchViewModel {
    private let indexService: SearchIndexServiceProtocol
    
    public var query: String = "" {
        didSet {
            debounceSearch()
        }
    }
    
    public var results: [SearchResult] = []
    public var isSearching: Bool = false
    public var selectedResultId: String? = nil
    
    private var searchTask: Task<Void, Never>?
    
    public init(indexService: SearchIndexServiceProtocol = LocalSearchIndexService()) {
        self.indexService = indexService
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        
        if query.isEmpty {
            results = []
            isSearching = false
            return
        }
        
        isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms debounce
            guard !Task.isCancelled else { return }
            
            let newResults = await indexService.performSearch(query: query)
            
            guard !Task.isCancelled else { return }
            self.results = newResults
            self.selectedResultId = newResults.first?.id
            self.isSearching = false
        }
    }
    
    public func executeSelected() {
        guard let selected = results.first(where: { $0.id == selectedResultId }) else { return }
        // Execution logic (e.g., routing) will be handled by the App Shell coordinator
        var logger = NovaLogger()
        logger.info("Executed search result: \(selected.title)", category: .general)
    }
}
