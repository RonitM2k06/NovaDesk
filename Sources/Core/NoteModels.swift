import Foundation
import SwiftData

@Model
public final class NoteFolder {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var creationDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \NoteModel.folder)
    public var notes: [NoteModel] = []
    
    public init(id: UUID = UUID(), name: String, creationDate: Date = Date()) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
    }
}

@Model
public final class NoteModel {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var content: String
    public var creationDate: Date
    public var lastModifiedDate: Date
    public var isFavorite: Bool
    public var tags: [String]
    
    public var folder: NoteFolder?
    
    // Optional linkage to a Project (stores the project's path or ID)
    public var linkedProjectId: String?
    
    public init(
        id: UUID = UUID(),
        title: String = "Untitled Note",
        content: String = "",
        creationDate: Date = Date(),
        lastModifiedDate: Date = Date(),
        isFavorite: Bool = false,
        tags: [String] = [],
        folder: NoteFolder? = nil,
        linkedProjectId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.isFavorite = isFavorite
        self.tags = tags
        self.folder = folder
        self.linkedProjectId = linkedProjectId
    }
}
