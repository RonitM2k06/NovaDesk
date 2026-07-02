# Contributing to NovaDesk

First off, thank you for considering contributing to NovaDesk! It's people like you that make NovaDesk a great tool for macOS developers.

## How Can I Contribute?

### Reporting Bugs
Bugs are tracked as GitHub issues. When creating an issue, please use the provided `bug_report.md` template. 
- Explain the problem and include additional details to help maintainers reproduce the problem.
- Ensure the bug was not already reported.

### Suggesting Enhancements
Enhancement suggestions are tracked as GitHub issues. Please use the `feature_request.md` template.

### Pull Requests
1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`swift test`).
5. Ensure your code passes SwiftLint.
6. Issue that pull request!

## Styleguides
- Use Swift 6 concurrency (`async/await`, `@MainActor`).
- Avoid UIKit/AppKit unless wrapped in Representables for missing SwiftUI functionality.
- Follow Clean Architecture: Do not place network/database logic in Views.
