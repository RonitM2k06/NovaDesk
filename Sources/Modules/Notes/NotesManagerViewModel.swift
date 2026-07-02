import SwiftUI
import Core
import SwiftData
import Observation

@MainActor
@Observable
public final class NotesManagerViewModel {
    private let notesService: NotesServiceProtocol
    
    public var folders: [NoteFolder] = []
    public var currentNotes: [NoteModel] = []
    
    public var selectedFolder: NoteFolder? = nil {
        didSet {
            loadNotes()
        }
    }
    public var selectedNote: NoteModel? = nil
    
    public var isCreatingFolder = false
    public var newFolderName = ""
    
    public init(notesService: NotesServiceProtocol = SwiftDataNotesService()) {
        self.notesService = notesService
        loadFolders()
        loadNotes()
    }
    
    public func loadFolders() {
        do {
            folders = try notesService.fetchFolders()
        } catch {
            // Log error
        }
    }
    
    public func loadNotes() {
        do {
            currentNotes = try notesService.fetchNotes(in: selectedFolder)
        } catch {
            // Log error
        }
    }
    
    public func createFolder() {
        guard !newFolderName.isEmpty else { return }
        do {
            _ = try notesService.createFolder(name: newFolderName)
            newFolderName = ""
            isCreatingFolder = false
            loadFolders()
        } catch {
            // Log error
        }
    }
    
    public func createNote() {
        do {
            let note = try notesService.createNote(title: "Untitled Note", in: selectedFolder)
            loadNotes()
            selectedNote = note
        } catch {
            // Log error
        }
    }
    
    public func delete(note: NoteModel) {
        do {
            try notesService.delete(note: note)
            if selectedNote?.id == note.id {
                selectedNote = nil
            }
            loadNotes()
        } catch {
            // Log error
        }
    }
    
    public func delete(folder: NoteFolder) {
        do {
            try notesService.delete(folder: folder)
            if selectedFolder?.id == folder.id {
                selectedFolder = nil
            }
            loadFolders()
        } catch {
            // Log error
        }
    }
    
    public func saveSelectedNote() {
        if let note = selectedNote {
            note.lastModifiedDate = Date()
            try? notesService.save()
        }
    }
}
