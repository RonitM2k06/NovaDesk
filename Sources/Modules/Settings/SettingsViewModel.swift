import SwiftUI
import Core

@MainActor
@Observable
public final class SettingsViewModel {
    private let preferencesService: PreferencesServiceProtocol
    
    public var preferences: UserPreferences
    public var hasUnsavedChanges: Bool = false
    public var saveError: String? = nil
    
    public init(preferencesService: PreferencesServiceProtocol = DependencyContainer.shared.resolve(PreferencesServiceProtocol.self)) {
        self.preferencesService = preferencesService
        self.preferences = preferencesService.preferences
    }
    
    public func save() {
        do {
            try preferencesService.save(preferences)
            hasUnsavedChanges = false
            saveError = nil
        } catch {
            saveError = "Failed to save settings: \(error.localizedDescription)"
        }
    }
    
    public func discardChanges() {
        self.preferences = preferencesService.preferences
        hasUnsavedChanges = false
        saveError = nil
    }
}
