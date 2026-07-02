// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NovaDesk",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // The main application executable
        .executable(
            name: "NovaDesk",
            targets: ["NovaDesk"]
        ),
        // Core layer: Models, Services, Architecture, Protocols
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        // Design System and Reusable UI Components
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]
        ),
        // Feature Modules (Dashboard, Git, Terminal, etc.)
        .library(
            name: "NovaModules",
            targets: ["NovaModules"]
        )
    ],
    dependencies: [
        // Terminal Emulation
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", branch: "main")
    ],
    targets: [
        // App entry point and window management
        .executableTarget(
            name: "NovaDesk",
            dependencies: [
                "Core",
                "UIComponents",
                "NovaModules"
            ],
            path: "Sources/App"
        ),
        // Core business logic and shared abstractions
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"
        ),
        // Reusable views and styling
        .target(
            name: "UIComponents",
            dependencies: [
                "Core"
            ],
            path: "Sources/UIComponents"
        ),
        // The distinct application features
        .target(
            name: "NovaModules",
            dependencies: [
                "Core",
                "UIComponents",
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ],
            path: "Sources/Modules"
        ),
        // Test suite
        .testTarget(
            name: "NovaDeskTests",
            dependencies: [
                "NovaDesk",
                "Core",
                "UIComponents",
                "NovaModules"
            ],
            path: "Tests/NovaDeskTests"
        )
    ]
)
