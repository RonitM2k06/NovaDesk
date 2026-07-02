import Foundation

public struct TerminalProfile: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var shellCommand: String
    public var workingDirectory: String?
    public var isDefault: Bool
    
    public init(id: UUID = UUID(), name: String, shellCommand: String, workingDirectory: String? = nil, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.shellCommand = shellCommand
        self.workingDirectory = workingDirectory
        self.isDefault = isDefault
    }
}

public struct TerminalSession: Identifiable, Equatable {
    public let id: UUID
    public let profile: TerminalProfile
    public var isActive: Bool
    
    public init(id: UUID = UUID(), profile: TerminalProfile, isActive: Bool = true) {
        self.id = id
        self.profile = profile
        self.isActive = isActive
    }
}

public struct TerminalTab: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var sessions: [TerminalSession]
    public var activeSessionId: UUID?
    
    public init(id: UUID = UUID(), title: String, sessions: [TerminalSession] = [], activeSessionId: UUID? = nil) {
        self.id = id
        self.title = title
        self.sessions = sessions
        self.activeSessionId = activeSessionId
    }
}
