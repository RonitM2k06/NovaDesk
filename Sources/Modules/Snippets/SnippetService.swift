import Foundation
import SwiftData
import Core

public protocol SnippetServiceProtocol {
    func fetchCategories() throws -> [SnippetCategory]
    func fetchSnippets(in category: SnippetCategory?) throws -> [SnippetModel]
    func createCategory(name: String) throws -> SnippetCategory
    func createSnippet(title: String, code: String, language: String, in category: SnippetCategory?) throws -> SnippetModel
    func delete(snippet: SnippetModel) throws
    func delete(category: SnippetCategory) throws
    func save() throws
}

@MainActor
public final class SwiftDataSnippetService: SnippetServiceProtocol {
    private let context: ModelContext
    
    public init(context: ModelContext = PersistenceController.shared.mainContext) {
        self.context = context
    }
    
    public func fetchCategories() throws -> [SnippetCategory] {
        let descriptor = FetchDescriptor<SnippetCategory>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    public func fetchSnippets(in category: SnippetCategory?) throws -> [SnippetModel] {
        if let category = category {
            let catId = category.id
            let descriptor = FetchDescriptor<SnippetModel>(
                predicate: #Predicate { $0.category?.id == catId },
                sortBy: [SortDescriptor(\.lastModifiedDate, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } else {
            let descriptor = FetchDescriptor<SnippetModel>(
                predicate: #Predicate { $0.category == nil },
                sortBy: [SortDescriptor(\.lastModifiedDate, order: .reverse)]
            )
            return try context.fetch(descriptor)
        }
    }
    
    public func createCategory(name: String) throws -> SnippetCategory {
        let category = SnippetCategory(name: name)
        context.insert(category)
        try save()
        return category
    }
    
    public func createSnippet(title: String, code: String, language: String, in category: SnippetCategory?) throws -> SnippetModel {
        let snippet = SnippetModel(title: title, code: code, language: language, category: category)
        context.insert(snippet)
        try save()
        return snippet
    }
    
    public func delete(snippet: SnippetModel) throws {
        context.delete(snippet)
        try save()
    }
    
    public func delete(category: SnippetCategory) throws {
        context.delete(category)
        try save()
    }
    
    public func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
