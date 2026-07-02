import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class GitViewModel {
    private let gitService: GitServiceProtocol
    
    public var currentRepositoryPath: String? {
        didSet {
            if currentRepositoryPath != nil {
                Task { await refreshAll() }
            } else {
                clearState()
            }
        }
    }
    
    public var branches: [GitBranch] = []
    public var currentBranch: GitBranch? {
        branches.first(where: { $0.isCurrent })
    }
    
    public var fileStatus: [GitFileStatus] = []
    public var history: [GitCommit] = []
    
    public var commitMessage: String = ""
    public var errorMessage: String? = nil
    public var isLoading: Bool = false
    
    public init(gitService: GitServiceProtocol = SystemGitService()) {
        self.gitService = gitService
    }
    
    private func clearState() {
        branches = []
        fileStatus = []
        history = []
        commitMessage = ""
        errorMessage = nil
    }
    
    public func refreshAll() async {
        guard let path = currentRepositoryPath else { return }
        isLoading = true
        errorMessage = nil
        
        async let fetchBranches = gitService.getBranches(in: path)
        async let fetchStatus = gitService.getStatus(in: path)
        async let fetchHistory = gitService.getHistory(in: path, limit: 100)
        
        do {
            let (newBranches, newStatus, newHistory) = try await (fetchBranches, fetchStatus, fetchHistory)
            self.branches = newBranches
            self.fileStatus = newStatus
            self.history = newHistory
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func stageFile(_ file: GitFileStatus) async {
        guard let path = currentRepositoryPath else { return }
        do {
            try await gitService.stage(files: [file.filePath], in: path)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func unstageFile(_ file: GitFileStatus) async {
        guard let path = currentRepositoryPath else { return }
        do {
            try await gitService.unstage(files: [file.filePath], in: path)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func stageAll() async {
        guard let path = currentRepositoryPath else { return }
        let unstaged = fileStatus.filter { !$0.isStaged }.map { $0.filePath }
        guard !unstaged.isEmpty else { return }
        
        do {
            try await gitService.stage(files: unstaged, in: path)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func commit() async {
        guard let path = currentRepositoryPath, !commitMessage.isEmpty else { return }
        do {
            try await gitService.commit(message: commitMessage, in: path)
            self.commitMessage = ""
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func checkout(branch: GitBranch) async {
        guard let path = currentRepositoryPath else { return }
        do {
            try await gitService.checkout(branch: branch.name, in: path)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
