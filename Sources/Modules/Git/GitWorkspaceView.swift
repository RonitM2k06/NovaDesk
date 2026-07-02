import SwiftUI
import Core
import UIComponents

public struct GitWorkspaceView: View {
    @State private var viewModel: GitViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: GitViewModel = GitViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            if viewModel.currentRepositoryPath == nil {
                emptyStateView
            } else {
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        // Left Sidebar: Branches
                        sidebarView
                            .frame(width: max(200, proxy.size.width * 0.2))
                        
                        Divider().background(theme.secondaryText.opacity(0.3))
                        
                        // Middle: Staging Area
                        stagingAreaView
                            .frame(width: max(300, proxy.size.width * 0.4))
                        
                        Divider().background(theme.secondaryText.opacity(0.3))
                        
                        // Right: History/Timeline
                        historyView
                            .frame(width: max(300, proxy.size.width * 0.4))
                    }
                }
            }
        }
        .background(theme.background)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                ProgressView()
                    .padding()
                    .background(theme.secondaryBackground)
                    .cornerRadius(8)
            }
        }
    }
    
    private var toolbarView: some View {
        HStack {
            Text("Git Workspace")
                .font(DesignSystem.Typography.subHeader)
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(theme.error)
            }
            
            Button("Open Repository") {
                // macOS Native Folder Picker
                #if os(macOS)
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                if panel.runModal() == .OK, let url = panel.url {
                    viewModel.currentRepositoryPath = url.path
                }
                #endif
            }
            .buttonStyle(.nova)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(theme.secondaryBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 64))
                .foregroundColor(theme.secondaryText)
            Text("No Repository Selected")
                .font(DesignSystem.Typography.header)
                .foregroundColor(theme.primaryText)
            Text("Open a folder containing a .git directory.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sidebarView: some View {
        List {
            Section(header: Text("Branches")) {
                ForEach(viewModel.branches) { branch in
                    HStack {
                        Image(systemName: branch.isCurrent ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(branch.isCurrent ? theme.success : theme.secondaryText)
                        Text(branch.name)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(branch.isCurrent ? theme.primaryText : theme.secondaryText)
                        if branch.isRemote {
                            Spacer()
                            Image(systemName: "cloud")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    .padding(.vertical, 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { await viewModel.checkout(branch: branch) }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    private var stagingAreaView: some View {
        VStack(spacing: 0) {
            // Unstaged Files
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Unstaged Changes")
                        .font(DesignSystem.Typography.subHeader)
                        .padding(DesignSystem.Spacing.medium)
                    Spacer()
                    Button("Stage All") {
                        Task { await viewModel.stageAll() }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, DesignSystem.Spacing.medium)
                }
                .background(theme.secondaryBackground)
                
                List {
                    let unstaged = viewModel.fileStatus.filter { !$0.isStaged }
                    ForEach(unstaged) { file in
                        HStack {
                            Text(file.status.rawValue.prefix(1).uppercased())
                                .font(DesignSystem.Typography.code)
                                .foregroundColor(theme.warning)
                            Text(file.filePath)
                                .font(DesignSystem.Typography.body)
                            Spacer()
                            Button(action: { Task { await viewModel.stageFile(file) } }) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            Divider()
            
            // Staged Files
            VStack(alignment: .leading, spacing: 0) {
                Text("Staged Changes")
                    .font(DesignSystem.Typography.subHeader)
                    .padding(DesignSystem.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.secondaryBackground)
                
                List {
                    let staged = viewModel.fileStatus.filter { $0.isStaged }
                    ForEach(staged) { file in
                        HStack {
                            Text(file.status.rawValue.prefix(1).uppercased())
                                .font(DesignSystem.Typography.code)
                                .foregroundColor(theme.success)
                            Text(file.filePath)
                                .font(DesignSystem.Typography.body)
                            Spacer()
                            Button(action: { Task { await viewModel.unstageFile(file) } }) {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            Divider()
            
            // Commit Box
            VStack(spacing: DesignSystem.Spacing.small) {
                TextEditor(text: $viewModel.commitMessage)
                    .frame(height: 80)
                    .border(theme.secondaryText.opacity(0.3))
                    .padding([.horizontal, .top], DesignSystem.Spacing.small)
                
                Button(action: {
                    Task { await viewModel.commit() }
                }) {
                    Text("Commit")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.nova)
                .padding([.horizontal, .bottom], DesignSystem.Spacing.small)
                .disabled(viewModel.commitMessage.isEmpty || !viewModel.fileStatus.contains(where: { $0.isStaged }))
            }
            .background(theme.secondaryBackground)
        }
    }
    
    private var historyView: some View {
        List {
            Section(header: Text("Commit History")) {
                ForEach(viewModel.history) { commit in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(commit.message)
                            .font(DesignSystem.Typography.body.weight(.medium))
                            .lineLimit(1)
                        HStack {
                            Text(commit.shortHash)
                                .font(DesignSystem.Typography.code)
                                .foregroundColor(theme.accent)
                            Text(commit.author)
                                .foregroundColor(theme.secondaryText)
                            Spacer()
                            Text(commit.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(theme.secondaryText)
                        }
                        .font(DesignSystem.Typography.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
    }
}
#if os(macOS)
import AppKit
#endif
