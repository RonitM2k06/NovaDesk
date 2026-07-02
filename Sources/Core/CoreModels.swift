import Foundation

/// Core domain models that are shared across the application.
public struct UserPreferences: Codable, Equatable {
    public var useDarkMode: Bool
    public var defaultTerminalShell: String
    public var defaultAIProvider: String
    public var enableTelemetry: Bool
    
    public init(
        useDarkMode: Bool = true,
        defaultTerminalShell: String = "/bin/zsh",
        defaultAIProvider: String = "OpenAI",
        enableTelemetry: Bool = false
    ) {
        self.useDarkMode = useDarkMode
        self.defaultTerminalShell = defaultTerminalShell
        self.defaultAIProvider = defaultAIProvider
        self.enableTelemetry = enableTelemetry
    }
}

/// A service protocol for managing user preferences.
public protocol PreferencesServiceProtocol {
    var preferences: UserPreferences { get }
    func save(_ preferences: UserPreferences) throws
}

/// Implementation of preferences service using UserDefaults.
public final class UserDefaultsPreferencesService: PreferencesServiceProtocol {
    private let defaults = UserDefaults.standard
    private let preferencesKey = "com.ronitmongia.NovaDesk.UserPreferences"
    
    public init() {}
    
    public var preferences: UserPreferences {
        if let data = defaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            return decoded
        }
        return UserPreferences()
    }
    
    public func save(_ preferences: UserPreferences) throws {
        let encoded = try JSONEncoder().encode(preferences)
        defaults.set(encoded, forKey: preferencesKey)
    }
}
