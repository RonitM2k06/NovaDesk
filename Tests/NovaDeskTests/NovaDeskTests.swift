import XCTest
@testable import Core
@testable import NovaModules

final class NovaDeskTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Set up dependency injection for tests
        DependencyContainer.shared.registerSingleton(PreferencesServiceProtocol.self, instance: MockPreferencesService())
    }
    
    override func tearDownWithError() throws {
        // Teardown code
    }
    
    @MainActor
    func testSettingsViewModelInitialState() throws {
        let viewModel = SettingsViewModel()
        XCTAssertFalse(viewModel.hasUnsavedChanges)
        XCTAssertNil(viewModel.saveError)
        XCTAssertEqual(viewModel.preferences.defaultAIProvider, "TestProvider")
    }
    
    @MainActor
    func testSettingsViewModelSave() throws {
        let viewModel = SettingsViewModel()
        viewModel.preferences.defaultAIProvider = "NewProvider"
        XCTAssertTrue(viewModel.hasUnsavedChanges)
        
        viewModel.save()
        
        XCTAssertFalse(viewModel.hasUnsavedChanges)
        XCTAssertNil(viewModel.saveError)
    }
}

// Mock service for testing
final class MockPreferencesService: PreferencesServiceProtocol {
    var preferences: UserPreferences = UserPreferences(defaultAIProvider: "TestProvider")
    
    func save(_ preferences: UserPreferences) throws {
        self.preferences = preferences
    }
}
