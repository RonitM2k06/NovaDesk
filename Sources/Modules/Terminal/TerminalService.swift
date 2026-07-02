import Foundation
#if os(macOS)
import SwiftTerm
import AppKit
#endif
import Core

public protocol TerminalServiceProtocol {
    func defaultProfile() -> TerminalProfile
    func getProfiles() -> [TerminalProfile]
}

public final class LocalTerminalService: TerminalServiceProtocol {
    public init() {}
    
    public func defaultProfile() -> TerminalProfile {
        return TerminalProfile(
            name: "Default Shell",
            shellCommand: ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh",
            isDefault: true
        )
    }
    
    public func getProfiles() -> [TerminalProfile] {
        return [
            defaultProfile(),
            TerminalProfile(name: "Bash", shellCommand: "/bin/bash"),
            TerminalProfile(name: "Python", shellCommand: "/usr/bin/env python3")
        ]
    }
}

// macOS Specific NSViewRepresentable for SwiftTerm
#if os(macOS)
import SwiftUI

public struct SwiftTermView: NSViewRepresentable {
    let session: TerminalSession
    
    public init(session: TerminalSession) {
        self.session = session
    }
    
    public func makeNSView(context: Context) -> LocalProcessTerminalView {
        let terminalView = LocalProcessTerminalView(frame: .zero)
        terminalView.startProcess(
            executable: session.profile.shellCommand,
            execName: nil,
            args: []
        )
        // Additional configuration for theming can be done here.
        return terminalView
    }
    
    public func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        // Handle updates (e.g., theme changes or font scaling)
    }
}
#else
import SwiftUI

public struct SwiftTermView: View {
    let session: TerminalSession
    
    public init(session: TerminalSession) {
        self.session = session
    }
    
    public var body: some View {
        Text("Terminal is only supported on macOS.")
    }
}
#endif
