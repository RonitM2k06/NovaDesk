import Foundation

/// Defines a detected software project on disk.
public struct ProjectModel: Codable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let path: String
    public let primaryLanguage: ProjectLanguage
    public let hasGit: Bool
    public let fileCount: Int
    public let totalSize: Int64
    public let lastModified: Date
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        path: String,
        primaryLanguage: ProjectLanguage,
        hasGit: Bool,
        fileCount: Int,
        totalSize: Int64,
        lastModified: Date,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.primaryLanguage = primaryLanguage
        self.hasGit = hasGit
        self.fileCount = fileCount
        self.totalSize = totalSize
        self.lastModified = lastModified
        self.isFavorite = isFavorite
    }
}

public enum ProjectLanguage: String, Codable, CaseIterable {
    case swift = "Swift"
    case python = "Python"
    case java = "Java"
    case nodejs = "Node.js"
    case rust = "Rust"
    case go = "Go"
    case cpp = "C++"
    case unknown = "Unknown"
    
    public var iconName: String {
        switch self {
        case .swift: return "swift" // Assuming custom assets or SF Symbols fallback
        case .python: return "p.square.fill"
        case .java: return "cup.and.saucer.fill"
        case .nodejs: return "n.square.fill"
        case .rust: return "r.square.fill"
        case .go: return "g.square.fill"
        case .cpp: return "c.square.fill"
        case .unknown: return "folder.fill"
        }
    }
    
    public var colorName: String {
        switch self {
        case .swift: return "orange"
        case .python: return "blue"
        case .java: return "red"
        case .nodejs: return "green"
        case .rust: return "brown"
        case .go: return "cyan"
        case .cpp: return "purple"
        case .unknown: return "gray"
        }
    }
}
