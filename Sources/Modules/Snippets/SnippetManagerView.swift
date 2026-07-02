import SwiftUI
import Core
import UIComponents

public struct SnippetManagerView: View {
    @State private var viewModel: SnippetViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: SnippetViewModel = SnippetViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationSplitView {
            categoryListView
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } content: {
            snippetListView
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            if let _ = viewModel.selectedSnippet {
                snippetEditorView
            } else {
                Text("Select a snippet or create a new one.")
                    .font(DesignSystem.Typography.subHeader)
                    .foregroundColor(theme.secondaryText)
            }
        }
        .background(theme.background)
    }
    
    private var categoryListView: some View {
        List(selection: $viewModel.selectedCategory) {
            Section(header: Text("Categories")) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(value: category) {
                        Label(category.name, systemImage: "folder")
                    }
                    .contextMenu {
                        // Omitted delete for brevity, handled similarly to notes
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.isCreatingCategory = true }) {
                    Label("New Category", systemImage: "folder.badge.plus")
                }
            }
        }
        .popover(isPresented: $viewModel.isCreatingCategory) {
            VStack {
                Text("New Category").font(DesignSystem.Typography.subHeader)
                TextField("Category Name", text: $viewModel.newCategoryName)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { viewModel.isCreatingCategory = false }
                    Button("Create") { viewModel.createCategory() }
                        .buttonStyle(.nova)
                }
            }
            .padding()
            .frame(width: 250)
        }
    }
    
    private var snippetListView: some View {
        List(selection: $viewModel.selectedSnippet) {
            ForEach(viewModel.currentSnippets) { snippet in
                NavigationLink(value: snippet) {
                    VStack(alignment: .leading) {
                        Text(snippet.title)
                            .font(DesignSystem.Typography.body.weight(.semibold))
                        HStack {
                            Text(snippet.language)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(theme.accent)
                            Spacer()
                            if snippet.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .contextMenu {
                    Button("Delete Snippet", role: .destructive) {
                        viewModel.delete(snippet: snippet)
                    }
                }
            }
        }
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.createSnippet() }) {
                    Label("New Snippet", systemImage: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    private var snippetEditorView: some View {
        if let selectedSnippet = viewModel.selectedSnippet {
            VStack(spacing: 0) {
                // Header
                HStack {
                    TextField("Snippet Title", text: Binding(
                        get: { selectedSnippet.title },
                        set: { selectedSnippet.title = $0; viewModel.saveSelectedSnippet() }
                    ))
                    .font(DesignSystem.Typography.header)
                    .textFieldStyle(.plain)
                    
                    Spacer()
                    
                    Picker("Language", selection: Binding(
                        get: { selectedSnippet.language },
                        set: { selectedSnippet.language = $0; viewModel.saveSelectedSnippet() }
                    )) {
                        ForEach(viewModel.availableLanguages, id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                    .frame(width: 150)
                    
                    Button(action: {
                        selectedSnippet.isFavorite.toggle()
                        viewModel.saveSelectedSnippet()
                    }) {
                        Image(systemName: selectedSnippet.isFavorite ? "star.fill" : "star")
                            .foregroundColor(selectedSnippet.isFavorite ? .yellow : theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { viewModel.copySnippetToClipboard() }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, DesignSystem.Spacing.small)
                }
                .padding()
                .background(theme.secondaryBackground)
                
                Divider()
                
                // Code Editor
                // Note: True syntax highlighting would use a library like Sourceful or standard TextEditor with NSAttributedString.
                TextEditor(text: Binding(
                    get: { selectedSnippet.code },
                    set: { selectedSnippet.code = $0; viewModel.saveSelectedSnippet() }
                ))
                .font(DesignSystem.Typography.code)
                .padding()
                .background(theme.background)
            }
        }
    }
}
