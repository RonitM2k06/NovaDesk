import Foundation

public struct GitCommit: Identifiable, Equatable {
    public let id: String // hash
    public let message: String
    public let author: String
    public let date: Date
    public let shortHash: String
    
    public init(id: String, message: String, author: String, date: Date) {
        self.id = id
        self.message = message
        self.author = author
        self.date = date
        self.shortHash = String(id.prefix(7))
    }
}

public struct GitBranch: Identifiable, Equatable {
    public var id: String { name }
    public let name: String
    public let isCurrent: Bool
    public let isRemote: Bool
    
    public init(name: String, isCurrent: Bool, isRemote: Bool = false) {
        self.name = name
        self.isCurrent = isCurrent
        self.isRemote = isRemote
    }
}

public struct GitFileStatus: Identifiable, Equatable {
    public var id: String { filePath }
    public let filePath: String
    public let status: StatusType
    public let isStaged: Bool
    
    public enum StatusType: String {
        case modified
        case added
        case deleted
        case untracked
        case renamed
        case unknown
    }
    
    public init(filePath: String, status: StatusType, isStaged: Bool) {
        self.filePath = filePath
        self.status = status
        self.isStaged = isStaged
    }
}
