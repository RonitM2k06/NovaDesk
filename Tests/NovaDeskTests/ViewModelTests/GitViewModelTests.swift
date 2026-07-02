import XCTest
@testable import Core
@testable import NovaModules

// Mock Git Service
final class MockGitService: GitServiceProtocol {
    var shouldFail = false
    
    func getBranches(in repositoryPath: String) async throws -> [GitBranch] {
        if shouldFail { throw GitError.notAGitRepository }
        return [GitBranch(name: "main", isCurrent: true), GitBranch(name: "feature-x", isCurrent: false)]
    }
    func getStatus(in repositoryPath: String) async throws -> [GitFileStatus] { return [] }
    func getHistory(in repositoryPath: String, limit: Int) async throws -> [GitCommit] { return [] }
    func commit(message: String, in repositoryPath: String) async throws {}
    func stage(files: [String], in repositoryPath: String) async throws {}
    func unstage(files: [String], in repositoryPath: String) async throws {}
    func checkout(branch: String, in repositoryPath: String) async throws {}
    func createBranch(name: String, in repositoryPath: String) async throws {}
    func push(in repositoryPath: String) async throws {}
    func pull(in repositoryPath: String) async throws {}
}

@MainActor
final class GitViewModelTests: XCTestCase {
    
    var viewModel: GitViewModel!
    var mockService: MockGitService!
    
    override func setUp() {
        super.setUp()
        mockService = MockGitService()
        viewModel = GitViewModel(gitService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testRefreshAllPopulatesState() async {
        viewModel.currentRepositoryPath = "/fake/repo"
        await viewModel.refreshAll()
        
        XCTAssertEqual(viewModel.branches.count, 2)
        XCTAssertEqual(viewModel.currentBranch?.name, "main")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testRefreshAllHandlesErrors() async {
        mockService.shouldFail = true
        viewModel.currentRepositoryPath = "/fake/repo"
        await viewModel.refreshAll()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.branches.isEmpty)
    }
}
