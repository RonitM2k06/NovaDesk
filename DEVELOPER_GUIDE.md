# Developer Guide

Welcome to the NovaDesk developer documentation.

## Project Structure
NovaDesk uses a flat, module-based SPM architecture:
- `App/`: The shell and window manager.
- `Core/`: Domain entities and dependencies.
- `UIComponents/`: Shared visual tokens.
- `Modules/`: Isolated features.

## Getting Started
1. Open `Package.swift` in Xcode 16.
2. Select the `NovaDesk` executable target.
3. Build and Run on macOS 15.0.

## Writing a New Module
1. **Define Models**: Place any persistent data models in `Sources/Core/` and register them in `PersistenceController`.
2. **Define Protocols**: Create protocols for your business logic to allow for mocking.
3. **Implement Services**: Place the concrete implementation in `Sources/Modules/YourModule/`.
4. **Create ViewModels**: Build an `@Observable` and `@MainActor` ViewModel that injects your service.
5. **Create Views**: Build the SwiftUI interface.
6. **Register**: Add your view to the `NavigationItem` enum in `MainSplitView`.

## Testing
We use standard `XCTest`. Run tests using `swift test` or via Xcode (Cmd+U). Ensure all new ViewModels and Services have corresponding Unit/Integration tests.
