import Foundation

public struct GitHubRepository: Codable, Identifiable, Equatable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let description: String?
    public let htmlUrl: String
    public let stargazersCount: Int
    public let language: String?
    public let privateRepo: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case privateRepo = "private"
    }
}

public struct GitHubIssue: Codable, Identifiable, Equatable {
    public let id: Int
    public let number: Int
    public let title: String
    public let state: String
    public let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, number, title, state
        case htmlUrl = "html_url"
    }
}

public struct GitHubUser: Codable, Identifiable, Equatable {
    public let id: Int
    public let login: String
    public let avatarUrl: String
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name
        case avatarUrl = "avatar_url"
    }
}
