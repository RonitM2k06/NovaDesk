# System Design

## Application Shell
NovaDesk is anchored by `MainSplitView.swift`, which serves as the router and primary presentation layer. It manages the Sidebar navigation and dynamically swaps out the detail view for the corresponding Workspace module.

## Modularity
We rely on Swift Package Manager (SPM) for strict isolation.
- `App`: The executable target containing `@main`.
- `Core`: Foundational models, DI container, Logging, and Persistence schema.
- `UIComponents`: The shared Design System, Typography, Colors, and reusable SwiftUI Modifiers (like `ToastModifier`).
- `NovaModules`: The actual feature implementations. 

## Data Persistence Strategy
1. **Relational / Rich Data**: Handled by **SwiftData**. This includes Notes, Note Folders, Snippets, Snippet Categories, AI Conversations, and AI Messages. Managed through the `PersistenceController` singleton localized in the `Core` module to provide `ModelContext` safely.
2. **Key-Value State**: Handled by `UserDefaults`. This includes Workspace Automation state (last opened project, window positions).
3. **Secure Credentials**: Handled by native macOS `Security` APIs (Keychain). This includes GitHub Personal Access Tokens and OpenAI API Keys.

## Concurrency Model
- Extensive use of `TaskGroup` (e.g., `ProjectScannerService`) to perform concurrent recursive file operations without blocking UI.
- All view models are annotated with `@MainActor` to guarantee UI updates occur on the main thread.
- Asynchronous networking utilizes `URLSession.shared.bytes(for:)` for low-latency streaming of large or continuous payloads (e.g., AI Chat Completions).
