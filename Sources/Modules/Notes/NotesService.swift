import Foundation
import SwiftData
import Core

public protocol NotesServiceProtocol {
    func fetchFolders() throws -> [NoteFolder]
    func fetchNotes(in folder: NoteFolder?) throws -> [NoteModel]
    func createFolder(name: String) throws -> NoteFolder
    func createNote(title: String, in folder: NoteFolder?) throws -> NoteModel
    func delete(note: NoteModel) throws
    func delete(folder: NoteFolder) throws
    func save() throws
}

@MainActor
public final class SwiftDataNotesService: NotesServiceProtocol {
    private let context: ModelContext
    
    public init(context: ModelContext = PersistenceController.shared.mainContext) {
        self.context = context
    }
    
    public func fetchFolders() throws -> [NoteFolder] {
        let descriptor = FetchDescriptor<NoteFolder>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    public func fetchNotes(in folder: NoteFolder?) throws -> [NoteModel] {
        if let folder = folder {
            let folderId = folder.id
            let descriptor = FetchDescriptor<NoteModel>(
                predicate: #Predicate { $0.folder?.id == folderId },
                sortBy: [SortDescriptor(\.lastModifiedDate, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } else {
            let descriptor = FetchDescriptor<NoteModel>(
                predicate: #Predicate { $0.folder == nil },
                sortBy: [SortDescriptor(\.lastModifiedDate, order: .reverse)]
            )
            return try context.fetch(descriptor)
        }
    }
    
    public func createFolder(name: String) throws -> NoteFolder {
        let folder = NoteFolder(name: name)
        context.insert(folder)
        try save()
        return folder
    }
    
    public func createNote(title: String, in folder: NoteFolder?) throws -> NoteModel {
        let note = NoteModel(title: title, folder: folder)
        context.insert(note)
        try save()
        return note
    }
    
    public func delete(note: NoteModel) throws {
        context.delete(note)
        try save()
    }
    
    public func delete(folder: NoteFolder) throws {
        context.delete(folder)
        try save()
    }
    
    public func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
