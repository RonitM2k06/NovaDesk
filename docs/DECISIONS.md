# Architectural Decisions

This document captures the rationale behind major technical decisions during the construction of NovaDesk.

## 1. Using SPM over `.xcodeproj`
**Decision:** Avoid manual Xcode project files entirely, favoring a multi-target Swift Package Manager (SPM) layout.
**Rationale:** It ensures strict module boundary enforcement, prevents git merge conflicts on project files, and keeps the project structure highly portable and scalable.

## 2. Abstraction of AI Providers
**Decision:** Use `AIProviderProtocol` and factories for OpenAI and Ollama, rather than hardcoding a single provider.
**Rationale:** Future-proofs the application. The AI landscape changes rapidly; allowing interchangeable providers ensures NovaDesk can swap in Anthropic, Gemini, or future local models without altering the UI logic.

## 3. Web-Bridged Markdown Rendering
**Decision:** Inject `marked.js`, `Mermaid.js`, and `MathJax` into a `WKWebView` via a Swift HTML bridging engine instead of natively parsing these with a Swift library.
**Rationale:** Native SwiftUI markdown lacks robust out-of-the-box Mermaid and Math support without pulling in massively bloated 3rd party dependencies. A web view bridge is lightweight, standard, and highly customizable.

## 4. Execution of System Git
**Decision:** Use Foundation's `Process` to directly execute `/usr/bin/git` instead of linking `libgit2` (ObjectiveGit).
**Rationale:** `libgit2` often trails behind mainline Git features and introduces complex C-interop linking. Executing the local binary guarantees feature parity with the user's terminal environment. We mitigate shell injection risks by passing explicit argument arrays (`Process.arguments`) rather than concatenating shell strings.

## 5. Security for API Keys
**Decision:** Abstract Keychain persistence (`MacOSKeychainService`) using `#if os(macOS)` compilation blocks over storing tokens in UserDefaults or plain text.
**Rationale:** Essential for a production-grade application to prevent token leakage.
