import Foundation
import Core

public protocol ProjectScannerServiceProtocol {
    func scanDirectories(_ urls: [URL]) async throws -> [ProjectModel]
    func openInFinder(project: ProjectModel)
    func openInTerminal(project: ProjectModel, shell: String)
}

public final class DefaultProjectScannerService: ProjectScannerServiceProtocol {
    private let fileManager = FileManager.default
    
    // In a real app, this cache would be persisted or time-bound.
    private var scanCache: [URL: ProjectModel] = [:]
    private let cacheLock = NSLock()
    
    public init() {}
    
    public func scanDirectories(_ urls: [URL]) async throws -> [ProjectModel] {
        return try await withThrowingTaskGroup(of: ProjectModel?.self) { group in
            for url in urls {
                group.addTask {
                    return self.scanDirectory(at: url)
                }
            }
            
            var projects: [ProjectModel] = []
            for try await project in group {
                if let project {
                    projects.append(project)
                }
            }
            return projects
        }
    }
    
    private func scanDirectory(at url: URL) -> ProjectModel? {
        // Check cache
        cacheLock.lock()
        if let cached = scanCache[url] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            return nil
        }
        
        // Detect Git
        let hasGit = fileManager.fileExists(atPath: url.appendingPathComponent(".git").path)
        
        // Analyze files (Shallow scan for performance)
        let (language, count, size) = analyzeProjectContents(url: url)
        
        // Skip non-projects (e.g. empty or generic folders)
        if language == .unknown && !hasGit {
            return nil
        }
        
        // Last modified
        let attrs = try? fileManager.attributesOfItem(atPath: url.path)
        let lastModified = attrs?[.modificationDate] as? Date ?? Date()
        
        let project = ProjectModel(
            name: url.lastPathComponent,
            path: url.path,
            primaryLanguage: language,
            hasGit: hasGit,
            fileCount: count,
            totalSize: size,
            lastModified: lastModified
        )
        
        cacheLock.lock()
        scanCache[url] = project
        cacheLock.unlock()
        
        return project
    }
    
    private func analyzeProjectContents(url: URL) -> (ProjectLanguage, Int, Int64) {
        var fileCount = 0
        var totalSize: Int64 = 0
        var extCounts: [String: Int] = [:]
        
        // Shallow enumeration for performance
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: options) {
            
            // Limit to 1000 files to avoid blocking forever on huge node_modules
            for case let fileURL as URL in enumerator {
                fileCount += 1
                if fileCount > 1000 { break }
                
                if let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let size = resources.fileSize {
                    totalSize += Int64(size)
                }
                
                let ext = fileURL.pathExtension.lowercased()
                extCounts[ext, default: 0] += 1
            }
        }
        
        // Determine primary language
        var language: ProjectLanguage = .unknown
        if fileManager.fileExists(atPath: url.appendingPathComponent("Package.swift").path) {
            language = .swift
        } else if fileManager.fileExists(atPath: url.appendingPathComponent("package.json").path) {
            language = .nodejs
        } else if fileManager.fileExists(atPath: url.appendingPathComponent("Cargo.toml").path) {
            language = .rust
        } else if fileManager.fileExists(atPath: url.appendingPathComponent("go.mod").path) {
            language = .go
        } else if fileManager.fileExists(atPath: url.appendingPathComponent("pom.xml").path) || fileManager.fileExists(atPath: url.appendingPathComponent("build.gradle").path) {
            language = .java
        } else if extCounts["swift"] ?? 0 > 0 {
            language = .swift
        } else if extCounts["py"] ?? 0 > 0 {
            language = .python
        } else if extCounts["cpp"] ?? 0 > 0 || extCounts["hpp"] ?? 0 > 0 {
            language = .cpp
        }
        
        return (language, fileCount, totalSize)
    }
    
    public func openInFinder(project: ProjectModel) {
        let url = URL(fileURLWithPath: project.path)
        #if os(macOS)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        #endif
    }
    
    public func openInTerminal(project: ProjectModel, shell: String) {
        // AppKit dependency to launch terminal app on macOS
        #if os(macOS)
        let url = URL(fileURLWithPath: project.path)
        NSWorkspace.shared.open([url], withAppBundleIdentifier: "com.apple.Terminal", options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
        #endif
    }
}
