import SwiftUI
import Core
import UIComponents

public struct TerminalManagerView: View {
    @State private var viewModel: TerminalViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: TerminalViewModel = TerminalViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            tabBarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            if let activeTab = viewModel.activeTab {
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        ForEach(Array(activeTab.sessions.enumerated()), id: \.element.id) { index, session in
                            VStack(spacing: 0) {
                                // Panes Header (optional, for split closing)
                                if activeTab.sessions.count > 1 {
                                    HStack {
                                        Text("Pane \(index + 1)")
                                            .font(DesignSystem.Typography.caption)
                                            .foregroundColor(activeTab.activeSessionId == session.id ? theme.accent : theme.secondaryText)
                                        Spacer()
                                        Button(action: {
                                            viewModel.activeTab?.activeSessionId = session.id
                                            viewModel.closeActiveSessionInTab()
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.caption)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(theme.secondaryBackground)
                                    
                                    Divider().background(theme.secondaryText.opacity(0.3))
                                }
                                
                                SwiftTermView(session: session)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .onTapGesture {
                                        viewModel.activeTab?.activeSessionId = session.id
                                    }
                            }
                            
                            if index < activeTab.sessions.count - 1 {
                                Divider().background(theme.secondaryText.opacity(0.3))
                            }
                        }
                    }
                }
            } else {
                emptyStateView
            }
        }
        .background(theme.background)
    }
    
    private var tabBarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.tabs) { tab in
                    let isActive = viewModel.activeTabId == tab.id
                    HStack {
                        Text(tab.title)
                            .font(DesignSystem.Typography.body.weight(isActive ? .medium : .regular))
                            .foregroundColor(isActive ? theme.primaryText : theme.secondaryText)
                        
                        Button(action: { viewModel.closeTab(id: tab.id) }) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(theme.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(isActive ? theme.background : theme.secondaryBackground)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(isActive ? theme.accent : .clear)
                        , alignment: .top
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.activeTabId = tab.id
                    }
                }
                
                Button(action: { viewModel.createNewTab() }) {
                    Image(systemName: "plus")
                        .foregroundColor(theme.secondaryText)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                
                Spacer()
                
                Button(action: { viewModel.splitActiveTab() }) {
                    Image(systemName: "square.split.2x1")
                        .foregroundColor(theme.secondaryText)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .disabled(viewModel.activeTab == nil)
            }
        }
        .background(theme.secondaryBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "terminal")
                .font(.system(size: 64))
                .foregroundColor(theme.secondaryText)
            Text("No Active Terminals")
                .font(DesignSystem.Typography.header)
                .foregroundColor(theme.primaryText)
            Button("Open New Terminal") {
                viewModel.createNewTab()
            }
            .buttonStyle(.nova)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
