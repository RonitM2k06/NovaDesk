import SwiftUI
import Core
import Observation
#if os(macOS)
import AppKit
#endif

@MainActor
@Observable
public final class ProjectManagerViewModel {
    private let scannerService: ProjectScannerServiceProtocol
    
    public var projects: [ProjectModel] = []
    public var isLoading: Bool = false
    public var searchQuery: String = ""
    public var filterLanguage: ProjectLanguage? = nil
    public var sortOrder: SortOrder = .lastModified
    
    public enum SortOrder: String, CaseIterable {
        case name = "Name"
        case lastModified = "Last Modified"
        case size = "Size"
    }
    
    public init(scannerService: ProjectScannerServiceProtocol = DependencyContainer.shared.resolve(ProjectScannerServiceProtocol.self)) {
        self.scannerService = scannerService
    }
    
    public var filteredAndSortedProjects: [ProjectModel] {
        var result = projects
        
        if !searchQuery.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
        
        if let filterLanguage {
            result = result.filter { $0.primaryLanguage == filterLanguage }
        }
        
        switch sortOrder {
        case .name:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .lastModified:
            result.sort { $0.lastModified > $1.lastModified }
        case .size:
            result.sort { $0.totalSize > $1.totalSize }
        }
        
        // Favorites always float to top
        result.sort { $0.isFavorite && !$1.isFavorite }
        
        return result
    }
    
    public func scanSelectedDirectory() async {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            await scan(urls: urls)
        }
        #endif
    }
    
    public func scan(urls: [URL]) async {
        isLoading = true
        do {
            let newProjects = try await scannerService.scanDirectories(urls)
            // Merge with existing, avoiding duplicates
            for proj in newProjects {
                if let index = projects.firstIndex(where: { $0.path == proj.path }) {
                    projects[index] = proj
                } else {
                    projects.append(proj)
                }
            }
        } catch {
            // log error
        }
        isLoading = false
    }
    
    public func toggleFavorite(for project: ProjectModel) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isFavorite.toggle()
        }
    }
    
    public func openInFinder(project: ProjectModel) {
        scannerService.openInFinder(project: project)
    }
    
    public func openInTerminal(project: ProjectModel) {
        let prefs = DependencyContainer.shared.resolve(PreferencesServiceProtocol.self).preferences
        scannerService.openInTerminal(project: project, shell: prefs.defaultTerminalShell)
    }
}
