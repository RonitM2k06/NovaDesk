import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class GitHubViewModel {
    private let apiClient: GitHubAPIClientProtocol
    private let keychainService: KeychainServiceProtocol
    private let accountName = "primary"
    
    public var userProfile: GitHubUser?
    public var repositories: [GitHubRepository] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var isConfigured: Bool = false
    public var patTokenInput: String = ""
    
    public init(
        apiClient: GitHubAPIClientProtocol = GitHubAPIClient(),
        keychainService: KeychainServiceProtocol = DependencyContainer.shared.resolve(KeychainServiceProtocol.self)
    ) {
        self.apiClient = apiClient
        self.keychainService = keychainService
        checkConfiguration()
    }
    
    public func checkConfiguration() {
        if let _ = try? keychainService.retrieve(for: accountName) {
            isConfigured = true
            Task { await loadData() }
        } else {
            isConfigured = false
        }
    }
    
    public func saveToken() {
        guard !patTokenInput.isEmpty else { return }
        do {
            try keychainService.save(token: patTokenInput, for: accountName)
            patTokenInput = ""
            checkConfiguration()
        } catch {
            errorMessage = "Failed to save token to Keychain."
        }
    }
    
    public func disconnect() {
        do {
            try keychainService.delete(for: accountName)
            isConfigured = false
            userProfile = nil
            repositories = []
        } catch {
            errorMessage = "Failed to remove token."
        }
    }
    
    public func loadData() async {
        guard let token = try? keychainService.retrieve(for: accountName) else { return }
        
        isLoading = true
        errorMessage = nil
        
        async let fetchProfile = apiClient.fetchUserProfile(token: token)
        async let fetchRepos = apiClient.fetchRepositories(token: token)
        
        do {
            let (profile, repos) = try await (fetchProfile, fetchRepos)
            self.userProfile = profile
            self.repositories = repos
        } catch GitHubAPIError.authenticationFailed {
            self.errorMessage = "Authentication failed. Token may be invalid or expired."
            disconnect()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
