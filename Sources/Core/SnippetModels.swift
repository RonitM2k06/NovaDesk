import Foundation
import SwiftData

@Model
public final class SnippetCategory {
    @Attribute(.unique) public var id: UUID
    public var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \SnippetModel.category)
    public var snippets: [SnippetModel] = []
    
    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@Model
public final class SnippetModel {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var code: String
    public var language: String
    public var isFavorite: Bool
    public var tags: [String]
    public var creationDate: Date
    public var lastModifiedDate: Date
    
    public var category: SnippetCategory?
    
    public init(
        id: UUID = UUID(),
        title: String = "Untitled Snippet",
        code: String = "",
        language: String = "Swift",
        isFavorite: Bool = false,
        tags: [String] = [],
        category: SnippetCategory? = nil,
        creationDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.code = code
        self.language = language
        self.isFavorite = isFavorite
        self.tags = tags
        self.category = category
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
    }
}
