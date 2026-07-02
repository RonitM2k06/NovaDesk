import SwiftUI
import UIComponents
import Core

public struct ProjectManagerView: View {
    @State private var viewModel: ProjectManagerViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: ProjectManagerViewModel = ProjectManagerViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Scanning directories...")
                    .foregroundColor(theme.primaryText)
                Spacer()
            } else if viewModel.projects.isEmpty {
                Spacer()
                emptyStateView
                Spacer()
            } else {
                projectListView
            }
        }
        .background(theme.background)
    }
    
    private var toolbarView: some View {
        HStack {
            TextField("Search projects...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            
            Spacer()
            
            Picker("Language", selection: $viewModel.filterLanguage) {
                Text("All Languages").tag(ProjectLanguage?.none)
                ForEach(ProjectLanguage.allCases, id: \.self) { lang in
                    Text(lang.rawValue).tag(ProjectLanguage?.some(lang))
                }
            }
            .frame(width: 150)
            
            Picker("Sort by", selection: $viewModel.sortOrder) {
                ForEach(ProjectManagerViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .frame(width: 150)
            
            Button(action: {
                Task {
                    await viewModel.scanSelectedDirectory()
                }
            }) {
                Label("Add Folder", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.nova)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(theme.secondaryBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "folder.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(theme.secondaryText)
            Text("No Projects Found")
                .font(DesignSystem.Typography.header)
                .foregroundColor(theme.primaryText)
            Text("Click 'Add Folder' to scan a directory for software projects.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(theme.secondaryText)
            
            Button("Add Folder") {
                Task {
                    await viewModel.scanSelectedDirectory()
                }
            }
            .buttonStyle(.nova)
            .padding(.top)
        }
    }
    
    private var projectListView: some View {
        List {
            ForEach(viewModel.filteredAndSortedProjects) { project in
                ProjectRow(project: project, viewModel: viewModel)
            }
        }
        // Native macOS list styling
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }
}

struct ProjectRow: View {
    let project: ProjectModel
    let viewModel: ProjectManagerViewModel
    @Environment(\.themePalette) private var theme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: project.primaryLanguage.iconName)
                .font(.system(size: 24))
                .foregroundColor(colorForLanguage(project.primaryLanguage))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(project.name)
                        .font(DesignSystem.Typography.subHeader)
                        .foregroundColor(theme.primaryText)
                    if project.hasGit {
                        Text("Git")
                            .font(DesignSystem.Typography.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.accent.opacity(0.2))
                            .foregroundColor(theme.accent)
                            .cornerRadius(4)
                    }
                    if project.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(project.path)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatSize(project.totalSize))
                    .font(DesignSystem.Typography.code)
                    .foregroundColor(theme.primaryText)
                Text("\(project.fileCount) files")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(theme.secondaryText)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.small)
        .contextMenu {
            Button(project.isFavorite ? "Unfavorite" : "Favorite") {
                viewModel.toggleFavorite(for: project)
            }
            Divider()
            Button("Open in Finder") {
                viewModel.openInFinder(project: project)
            }
            Button("Open in Terminal") {
                viewModel.openInTerminal(project: project)
            }
        }
    }
    
    private func colorForLanguage(_ lang: ProjectLanguage) -> Color {
        switch lang {
        case .swift: return .orange
        case .python: return .blue
        case .java: return .red
        case .nodejs: return .green
        case .rust: return .brown
        case .go: return .cyan
        case .cpp: return .purple
        case .unknown: return theme.secondaryText
        }
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
