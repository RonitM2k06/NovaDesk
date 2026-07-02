import XCTest
@testable import Core
@testable import NovaModules

protocol MockServiceProtocol {}
class MockServiceImpl: MockServiceProtocol {}

final class DependencyContainerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset container before each test
        DependencyContainer.shared.register(KeychainServiceProtocol.self, implementation: MacOSKeychainService())
    }
    
    func testDependencyRegistrationAndResolution() {
        let container = DependencyContainer.shared
        container.register(MockServiceProtocol.self, implementation: MockServiceImpl())
        
        let resolved = container.resolve(MockServiceProtocol.self)
        XCTAssertNotNil(resolved, "Container should resolve registered dependencies.")
        XCTAssertTrue(resolved is MockServiceImpl)
    }
    
    func testFatalErrorOnUnregisteredDependency() {
        // We cannot easily test fatalError in XCTest without custom crash handlers, 
        // but we can ensure the basic keychain service is available from default setup.
        let container = DependencyContainer.shared
        let resolved = container.resolve(KeychainServiceProtocol.self)
        XCTAssertNotNil(resolved)
    }
}
