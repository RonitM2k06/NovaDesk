import Foundation
import SwiftData

public enum AIRole: String, Codable {
    case user
    case assistant
    case system
}

@Model
public final class AIMessage {
    @Attribute(.unique) public var id: UUID
    public var roleString: String
    public var content: String
    public var timestamp: Date
    
    @Relationship(inverse: \AIConversation.messages)
    public var conversation: AIConversation?
    
    public var role: AIRole {
        get { AIRole(rawValue: roleString) ?? .user }
        set { roleString = newValue.rawValue }
    }
    
    public init(id: UUID = UUID(), role: AIRole, content: String, timestamp: Date = Date(), conversation: AIConversation? = nil) {
        self.id = id
        self.roleString = role.rawValue
        self.content = content
        self.timestamp = timestamp
        self.conversation = conversation
    }
}

@Model
public final class AIConversation {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var isPinned: Bool
    
    @Relationship(deleteRule: .cascade)
    public var messages: [AIMessage] = []
    
    public init(id: UUID = UUID(), title: String = "New Conversation", createdAt: Date = Date(), updatedAt: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }
}
