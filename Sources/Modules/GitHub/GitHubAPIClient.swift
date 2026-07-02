import Foundation
import Core

public protocol GitHubAPIClientProtocol {
    func fetchRepositories(token: String) async throws -> [GitHubRepository]
    func fetchUserProfile(token: String) async throws -> GitHubUser
}

public enum GitHubAPIError: Error {
    case invalidURL
    case authenticationFailed
    case requestFailed(statusCode: Int)
    case decodingFailed
}

public final class GitHubAPIClient: GitHubAPIClientProtocol {
    private let baseURL = "https://api.github.com"
    private let session = URLSession.shared
    
    public init() {}
    
    private func makeRequest(endpoint: String, token: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw GitHubAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public func fetchRepositories(token: String) async throws -> [GitHubRepository] {
        let request = try makeRequest(endpoint: "/user/repos?sort=updated&per_page=100", token: token)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.requestFailed(statusCode: 0)
        }
        
        if httpResponse.statusCode == 401 {
            throw GitHubAPIError.authenticationFailed
        } else if httpResponse.statusCode != 200 {
            throw GitHubAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([GitHubRepository].self, from: data)
        } catch {
            throw GitHubAPIError.decodingFailed
        }
    }
    
    public func fetchUserProfile(token: String) async throws -> GitHubUser {
        let request = try makeRequest(endpoint: "/user", token: token)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.requestFailed(statusCode: 0)
        }
        
        if httpResponse.statusCode == 401 {
            throw GitHubAPIError.authenticationFailed
        } else if httpResponse.statusCode != 200 {
            throw GitHubAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(GitHubUser.self, from: data)
        } catch {
            throw GitHubAPIError.decodingFailed
        }
    }
}
