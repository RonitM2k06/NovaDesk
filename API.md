# NovaDesk API Overview

While NovaDesk is primarily a GUI application, it exposes several internal Swift protocols that are strictly followed across the application. These APIs allow for rapid extension.

## AIProviderProtocol
```swift
public protocol AIProviderProtocol {
    func sendMessageStream(_ message: String, history: [AIMessage], context: String?) async throws -> AsyncThrowingStream<String, Error>
}
```
**Purpose:** Provides an abstraction for AI inference. 
**Usage:** Implement this protocol to add custom models (e.g., Anthropic, Gemini, or custom REST endpoints).

## GitServiceProtocol
```swift
public protocol GitServiceProtocol {
    func getBranches(in repositoryPath: String) async throws -> [GitBranch]
    func getStatus(in repositoryPath: String) async throws -> [GitFileStatus]
    func getHistory(in repositoryPath: String, limit: Int) async throws -> [GitCommit]
    // ...
}
```
**Purpose:** Wraps standard Git operations.
**Usage:** Currently implemented using `SystemGitService` which spawns `/usr/bin/git`. Can be overridden with a `libgit2` implementation if required.

## SearchIndexServiceProtocol
```swift
public protocol SearchIndexServiceProtocol {
    func performSearch(query: String) async -> [SearchResult]
    func reindexAll() async
    // ...
}
```
**Purpose:** Powers the `GlobalSearchView`. 
**Usage:** Injects search results for external plugins.
