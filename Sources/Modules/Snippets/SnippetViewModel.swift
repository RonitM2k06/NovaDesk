import SwiftUI
import Core
import Observation
#if os(macOS)
import AppKit
#endif

@MainActor
@Observable
public final class SnippetViewModel {
    private let snippetService: SnippetServiceProtocol
    
    public var categories: [SnippetCategory] = []
    public var currentSnippets: [SnippetModel] = []
    
    public var selectedCategory: SnippetCategory? = nil {
        didSet { loadSnippets() }
    }
    public var selectedSnippet: SnippetModel? = nil
    
    public var isCreatingCategory = false
    public var newCategoryName = ""
    
    public let availableLanguages = ["Swift", "Java", "Python", "C++", "SQL", "Bash", "Markdown", "JSON"]
    
    public init(snippetService: SnippetServiceProtocol = SwiftDataSnippetService()) {
        self.snippetService = snippetService
        loadCategories()
        loadSnippets()
    }
    
    public func loadCategories() {
        do {
            categories = try snippetService.fetchCategories()
        } catch {
            // Log error
        }
    }
    
    public func loadSnippets() {
        do {
            currentSnippets = try snippetService.fetchSnippets(in: selectedCategory)
        } catch {
            // Log error
        }
    }
    
    public func createCategory() {
        guard !newCategoryName.isEmpty else { return }
        do {
            _ = try snippetService.createCategory(name: newCategoryName)
            newCategoryName = ""
            isCreatingCategory = false
            loadCategories()
        } catch {
            // Log error
        }
    }
    
    public func createSnippet() {
        do {
            let snippet = try snippetService.createSnippet(title: "New Snippet", code: "", language: "Swift", in: selectedCategory)
            loadSnippets()
            selectedSnippet = snippet
        } catch {
            // Log error
        }
    }
    
    public func delete(snippet: SnippetModel) {
        do {
            try snippetService.delete(snippet: snippet)
            if selectedSnippet?.id == snippet.id {
                selectedSnippet = nil
            }
            loadSnippets()
        } catch {
            // Log error
        }
    }
    
    public func saveSelectedSnippet() {
        if let snippet = selectedSnippet {
            snippet.lastModifiedDate = Date()
            try? snippetService.save()
        }
    }
    
    public func copySnippetToClipboard() {
        #if os(macOS)
        guard let code = selectedSnippet?.code else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(code, forType: .string)
        #endif
    }
}
