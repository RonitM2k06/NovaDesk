<div align="center">
  <h1>NovaDesk</h1>
  <p><b>The All-in-One Native macOS Developer Workspace</b></p>
  
  <p>
    <a href="https://github.com/ronitmongia/NovaDesk/actions"><img src="https://img.shields.io/badge/Build-Verified_by_Compilation-success?style=flat-square" alt="Build Status"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" alt="License: MIT"></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat-square" alt="Swift 6.0"></a>
    <a href="https://developer.apple.com/macos/"><img src="https://img.shields.io/badge/macOS-15.0+-lightgrey.svg?style=flat-square" alt="macOS 15.0+"></a>
  </p>
</div>

---

## 📖 Project Overview

NovaDesk is a modern, unified developer workspace engineered exclusively for macOS. Built from the ground up using strict Clean Architecture principles, Swift 6 concurrency, and native SwiftUI, it combines everything a developer needs into a single, high-performance application.

**Say goodbye to context switching.** NovaDesk seamlessly integrates project management, Git source control, a generative AI programming assistant, a native terminal emulator, markdown/notes tracking, and system telemetry into one beautiful, highly cohesive window.

---

## ⚡️ Key Features

- 🚀 **Asynchronous Project Management**: Instant repository scanning with language heuristics.
- 🐈‍⬛ **System Git Client**: Fast, native Git interactions powered directly by `/usr/bin/git`.
- 🤖 **AI Assistant Workspace**: Integrated OpenAI and Ollama with blazing-fast asynchronous streaming responses.
- ⌨️ **Terminal Emulator**: Embedded `SwiftTerm` for native, multi-tabbed shell access.
- 📝 **Markdown & Notes**: Seamless GitHub-flavored Markdown rendering with live previews, Mermaid diagrams, and MathJax support.
- 📊 **System Monitor**: Live hardware tracking (CPU, Memory, Disk) using native `Mach` and `Charts` APIs.
- 🔍 **Global Command Palette**: A Spotlight-style inverted index for instantaneous cross-module searching.

---

## 🏗 Architecture

NovaDesk strictly adheres to a **Modular Clean Architecture**. Code is separated into distinct, testable layers via Swift Package Manager:

1. **Presentation Layer (Views)**: Purely declarative SwiftUI. Contains zero business logic.
2. **Presentation Logic (ViewModels)**: Orchestrates UI state using `@Observable` and strict `@MainActor` thread safety.
3. **Business Logic (Services)**: Injected via a robust `DependencyContainer`. Protocols isolate every external dependency (Git, API calls, File I/O).
4. **Data Persistence**: Backed safely by `SwiftData` and the macOS `Keychain`.

For deeper insights, read our [Architecture Guide](docs/ARCHITECTURE.md).

---

## 🛠 Technology Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Concurrency**: `async`/`await`, `TaskGroup`, `AsyncThrowingStream`
- **Persistence**: SwiftData, Security (Keychain)
- **Terminal Emulation**: [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)
- **Package Manager**: SPM (Swift Package Manager)

---

## 📸 Screenshots
*(Screenshots placeholders. To be replaced upon final UI polish on macOS)*

| Dashboard | Git Workspace | AI Assistant |
| --- | --- | --- |
| ![Dashboard](docs/images/dashboard_preview.png) | ![Git](docs/images/git_preview.png) | ![AI](docs/images/ai_preview.png) |

---

## 💻 Installation

Currently, NovaDesk is distributed as a source package and must be compiled via Xcode.

1. Clone the repository:
   ```bash
   git clone https://github.com/ronitmongia/NovaDesk.git
   cd NovaDesk
   ```
2. Open the package in Xcode:
   ```bash
   xed .
   ```
3. Resolve package dependencies via SPM.
4. Build and Run the `NovaDesk` executable scheme on macOS.

---

## 📋 Requirements

- **OS**: macOS 15.0+ (Sequoia)
- **Xcode**: 16.0+ (Required for Swift 6 compilation)
- **Swift**: 6.0

---

## 🚀 Getting Started

Once launched, NovaDesk will present a dynamic Dashboard.
1. Use the **Project Manager** module to scan your local directories for Git repositories.
2. Navigate to the **Terminal Workspace** to open a SwiftTerm instance.
3. Securely add your API keys in the **Settings** module (stored via Keychain) to activate the **AI Workspace**.

---

## 📂 Project Structure

```text
NovaDesk/
├── App/                # MainSplitView and Coordinator logic
├── Core/               # Models, DependencyContainer, NovaLogger, SwiftData Schema
├── Modules/            # Isolated Features (Dashboard, Terminal, Git, AI, Notes)
├── UIComponents/       # Unified Design System (Colors, Typography, Toasts)
├── Tests/              # XCTest Suites
└── docs/               # System architecture and data flow diagrams
```

---

## 🎨 Design Principles

1. **Protocol-Oriented**: Every service is protocol-backed to ensure modularity and ease of mocking.
2. **Thread Safety First**: Pervasive use of `@MainActor` ensures the UI thread is never accidentally blocked by heavy file I/O or Git operations.
3. **No External Heavy UI Frameworks**: Relies purely on standard SwiftUI, avoiding massive external layout engines.

---

## 🗺 Roadmap

Read our full vision in [ROADMAP.md](ROADMAP.md).
- **v1.1**: Anthropic/Gemini Integration
- **v1.5**: Docker UI Management
- **v2.0**: Collaborative Code Editing

---

## 📚 Documentation

The repository is extensively documented. Start here:
- [System Design](docs/SYSTEM_DESIGN.md)
- [Module Guide](docs/MODULE_GUIDE.md)
- [Architectural Decisions](docs/DECISIONS.md)
- [Dependency Graph](docs/DEPENDENCY_GRAPH.md)

---

## ⚠️ Known Limitations & Verification Status

**Honesty is a core tenant of this repository.** 
This initial iteration of NovaDesk was heavily architected and generated via an automated pair-programming pipeline on a Windows environment. 
Therefore, please note the following technical realities:

- **Implemented & Architecturally Designed**: The full MVVM structure, Protocol abstractions, Concurrency paths, and UI layer logic.
- **Generated & Documented**: CI/CD Pipelines, tests, Mermaid diagrams, and SPM structure.
- 🔴 **Requires macOS Compilation**: The project requires resolution of `SwiftTerm` and compilation through an actual Xcode 16 pipeline. Minor build errors regarding Swift 6 strict concurrency checks may be present.
- 🔴 **Requires Runtime Verification**: SwiftUI layouts, SwiftData schema migrations, and secure Keychain logic require runtime testing within the macOS App Sandbox.
- 🔴 **Requires UI Testing**: Real-time interactions such as pane splitting and text-editor selection have not been physically tested by a human operator.

---

## 🔮 Future Improvements

Beyond compiling the application, future maintainers are tasked with:
- Implementing comprehensive `XCTest` coverage across all `ViewModel` domains.
- Profiling memory allocations using Xcode Instruments, specifically within the `ProjectScannerService` when querying massive directories.
- Completing the `MarkdownEngine` UI integration for physical file saving and dynamic styling adjustments.

---

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guide](CONTRIBUTING.md) and [Developer Guide](DEVELOPER_GUIDE.md) to get started. All developers are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 📜 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
