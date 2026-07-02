import SwiftUI
import Core
import UIComponents

public struct NotesManagerView: View {
    @State private var viewModel: NotesManagerViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: NotesManagerViewModel = NotesManagerViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationSplitView {
            folderListView
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } content: {
            noteListView
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            if let _ = viewModel.selectedNote {
                noteEditorView
            } else {
                Text("Select a note or create a new one.")
                    .font(DesignSystem.Typography.subHeader)
                    .foregroundColor(theme.secondaryText)
            }
        }
        .background(theme.background)
    }
    
    private var folderListView: some View {
        List(selection: $viewModel.selectedFolder) {
            Section(header: Text("Folders")) {
                ForEach(viewModel.folders) { folder in
                    NavigationLink(value: folder) {
                        Label(folder.name, systemImage: "folder")
                    }
                    .contextMenu {
                        Button("Delete Folder", role: .destructive) {
                            viewModel.delete(folder: folder)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.isCreatingFolder = true }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
            }
        }
        .popover(isPresented: $viewModel.isCreatingFolder) {
            VStack {
                Text("New Folder").font(DesignSystem.Typography.subHeader)
                TextField("Folder Name", text: $viewModel.newFolderName)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { viewModel.isCreatingFolder = false }
                    Button("Create") { viewModel.createFolder() }
                        .buttonStyle(.nova)
                }
            }
            .padding()
            .frame(width: 250)
        }
    }
    
    private var noteListView: some View {
        List(selection: $viewModel.selectedNote) {
            ForEach(viewModel.currentNotes) { note in
                NavigationLink(value: note) {
                    VStack(alignment: .leading) {
                        Text(note.title.isEmpty ? "Untitled" : note.title)
                            .font(DesignSystem.Typography.body.weight(.semibold))
                        Text(note.lastModifiedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(theme.secondaryText)
                    }
                }
                .contextMenu {
                    Button("Delete Note", role: .destructive) {
                        viewModel.delete(note: note)
                    }
                }
            }
        }
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.createNote() }) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
            }
        }
    }
    
    @ViewBuilder
    private var noteEditorView: some View {
        if let selectedNote = viewModel.selectedNote {
            // Note Editor wrapper with autosave binding
            VStack(spacing: 0) {
                TextField("Note Title", text: Binding(
                    get: { selectedNote.title },
                    set: { 
                        selectedNote.title = $0
                        viewModel.saveSelectedNote()
                    }
                ))
                .font(DesignSystem.Typography.header)
                .textFieldStyle(.plain)
                .padding()
                
                Divider()
                
                TextEditor(text: Binding(
                    get: { selectedNote.content },
                    set: { 
                        selectedNote.content = $0
                        viewModel.saveSelectedNote()
                    }
                ))
                .font(DesignSystem.Typography.body)
                .padding()
            }
        }
    }
}
