import SwiftUI
import Core
import UIComponents

public struct GlobalSearchView: View {
    @State private var viewModel: SearchViewModel
    @Environment(\.themePalette) private var theme
    
    // In a real macOS app, this would be presented as an NSPanel (Spotlight style)
    // Here we build the SwiftUI content for that panel.
    
    public init(viewModel: SearchViewModel = SearchViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(theme.secondaryText)
                
                TextField("Search projects, notes, snippets, or commands...", text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.subHeader)
                    .foregroundColor(theme.primaryText)
                    .onSubmit {
                        viewModel.executeSelected()
                    }
                
                if viewModel.isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(DesignSystem.Spacing.large)
            .background(theme.secondaryBackground)
            
            if !viewModel.results.isEmpty {
                Divider().background(theme.secondaryText.opacity(0.3))
                
                List(selection: $viewModel.selectedResultId) {
                    ForEach(viewModel.results) { result in
                        SearchResultRow(result: result)
                            .tag(result.id)
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 400)
            } else if !viewModel.query.isEmpty && !viewModel.isSearching {
                Divider().background(theme.secondaryText.opacity(0.3))
                
                VStack {
                    Text("No results found.")
                        .foregroundColor(theme.secondaryText)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(theme.background)
            }
        }
        .frame(width: 600)
        .background(theme.background)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    @Environment(\.themePalette) private var theme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: iconForType(result.type))
                .foregroundColor(theme.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(DesignSystem.Typography.body.weight(.medium))
                    .foregroundColor(theme.primaryText)
                
                if let sub = result.subtitle {
                    Text(sub)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(theme.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(result.type.rawValue)
                .font(DesignSystem.Typography.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(theme.secondaryText.opacity(0.2))
                .foregroundColor(theme.secondaryText)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private func iconForType(_ type: SearchResultType) -> String {
        switch type {
        case .project: return "folder"
        case .note: return "note.text"
        case .snippet: return "curlybraces.square"
        case .gitCommit: return "arrow.triangle.branch"
        case .setting: return "gearshape"
        case .command: return "terminal"
        }
    }
}
