import Foundation

public enum SearchResultType: String, Codable {
    case project = "Project"
    case note = "Note"
    case snippet = "Snippet"
    case gitCommit = "Git Commit"
    case setting = "Setting"
    case command = "Command"
}

public struct SearchResult: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let type: SearchResultType
    public let score: Double // Used for ranking
    public let targetPathOrId: String
    
    public init(id: String = UUID().uuidString, title: String, subtitle: String? = nil, type: SearchResultType, score: Double, targetPathOrId: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.score = score
        self.targetPathOrId = targetPathOrId
    }
}
