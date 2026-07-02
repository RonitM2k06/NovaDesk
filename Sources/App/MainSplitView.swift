import SwiftUI
import UIComponents
import NovaModules // Integrate feature views

/// Enum representing the primary navigation modules in the sidebar.
public enum NavigationItem: String, CaseIterable, Hashable, Identifiable {
    case dashboard = "Dashboard"
    case projects = "Projects"
    case git = "Git"
    case terminal = "Terminal"
    case ai = "AI Assistant"
    case markdown = "Markdown"
    case notes = "Notes"
    case snippets = "Snippets"
    case monitor = "System Monitor"
    case github = "GitHub"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var systemImage: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .projects: return "folder"
        case .git: return "arrow.triangle.branch"
        case .terminal: return "terminal"
        case .ai: return "sparkles"
        case .markdown: return "doc.text"
        case .notes: return "note.text"
        case .snippets: return "curlybraces.square"
        case .monitor: return "chart.xyaxis.line"
        case .github: return "cat"
        case .settings: return "gearshape"
        }
    }
}

public struct MainSplitView: View {
    @State private var selectedItem: NavigationItem? = .dashboard
    @Environment(\.themePalette) private var theme
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            List(NavigationItem.allCases, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.systemImage)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(selectedItem == item ? theme.accent : theme.primaryText)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("NovaDesk")
        } detail: {
            Group {
                if let selectedItem {
                    switch selectedItem {
                    case .dashboard:
                        DashboardView()
                    case .projects:
                        ProjectManagerView()
                    case .notes:
                        NotesManagerView()
                    case .markdown:
                        MarkdownWorkspaceView()
                    case .git:
                        GitWorkspaceView()
                    case .github:
                        GitHubIntegrationView()
                    case .search:
                        GlobalSearchView() // Wait, search is usually a modal, but we can render it as a view if requested.
                    case .snippets:
                        SnippetManagerView()
                    case .monitor:
                        SystemMonitorView()
                    case .settings:
                        SettingsView()
                    default:
                        // Phase 4/5 Placeholders
                        VStack {
                            Image(systemName: selectedItem.systemImage)
                                .font(.system(size: 64))
                                .foregroundColor(theme.accent)
                                .padding()
                            Text("\(selectedItem.rawValue) Workspace")
                                .font(DesignSystem.Typography.header)
                                .foregroundColor(theme.primaryText)
                            Text("Coming in a future phase.")
                                .foregroundColor(theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(theme.background)
                    }
                } else {
                    Text("Select a workspace from the sidebar")
                        .font(DesignSystem.Typography.subHeader)
                        .foregroundColor(theme.secondaryText)
                }
            }
        }
        .background(theme.secondaryBackground)
    }
}
