import Foundation
import Core

public enum GitError: Error, LocalizedError {
    case executionFailed(exitCode: Int, stderr: String)
    case notAGitRepository
    case parsingFailed
    case invalidPath
    
    public var errorDescription: String? {
        switch self {
        case .executionFailed(let code, let stderr):
            return "Git command failed (Exit code \(code)): \(stderr)"
        case .notAGitRepository:
            return "Not a git repository."
        case .parsingFailed:
            return "Failed to parse Git output."
        case .invalidPath:
            return "Invalid repository path."
        }
    }
}

public protocol GitServiceProtocol {
    func getBranches(in repositoryPath: String) async throws -> [GitBranch]
    func getStatus(in repositoryPath: String) async throws -> [GitFileStatus]
    func getHistory(in repositoryPath: String, limit: Int) async throws -> [GitCommit]
    func commit(message: String, in repositoryPath: String) async throws
    func stage(files: [String], in repositoryPath: String) async throws
    func unstage(files: [String], in repositoryPath: String) async throws
    func checkout(branch: String, in repositoryPath: String) async throws
    func createBranch(name: String, in repositoryPath: String) async throws
    func push(in repositoryPath: String) async throws
    func pull(in repositoryPath: String) async throws
}

public final class SystemGitService: GitServiceProtocol {
    
    public init() {}
    
    private func executeGit(args: [String], in path: String) async throws -> String {
        guard FileManager.default.fileExists(atPath: URL(fileURLWithPath: path).appendingPathComponent(".git").path) else {
            throw GitError.notAGitRepository
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try process.run()
                process.waitUntilExit()
                
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stdoutString = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderrString = String(data: stderrData, encoding: .utf8) ?? ""
                
                if process.terminationStatus == 0 {
                    continuation.resume(returning: stdoutString)
                } else {
                    continuation.resume(throwing: GitError.executionFailed(exitCode: Int(process.terminationStatus), stderr: stderrString))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func getBranches(in repositoryPath: String) async throws -> [GitBranch] {
        let output = try await executeGit(args: ["branch", "--list", "--all"], in: repositoryPath)
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        var branches = [GitBranch]()
        for line in lines {
            let isCurrent = line.hasPrefix("*")
            let rawName = line.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
            
            if rawName.hasPrefix("remotes/") {
                branches.append(GitBranch(name: rawName.replacingOccurrences(of: "remotes/", with: ""), isCurrent: isCurrent, isRemote: true))
            } else {
                branches.append(GitBranch(name: rawName, isCurrent: isCurrent, isRemote: false))
            }
        }
        return branches
    }
    
    public func getStatus(in repositoryPath: String) async throws -> [GitFileStatus] {
        let output = try await executeGit(args: ["status", "--porcelain"], in: repositoryPath)
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        return lines.compactMap { line -> GitFileStatus? in
            guard line.count >= 3 else { return nil }
            let indexStatus = line[line.startIndex]
            let workTreeStatus = line[line.index(after: line.startIndex)]
            let filePath = String(line.dropFirst(3))
            
            let isStaged = indexStatus != " " && indexStatus != "?"
            
            var statusType: GitFileStatus.StatusType = .unknown
            let checkStatus = isStaged ? indexStatus : workTreeStatus
            
            switch checkStatus {
            case "M": statusType = .modified
            case "A": statusType = .added
            case "D": statusType = .deleted
            case "R": statusType = .renamed
            case "?": statusType = .untracked
            default: break
            }
            
            return GitFileStatus(filePath: filePath, status: statusType, isStaged: isStaged)
        }
    }
    
    public func getHistory(in repositoryPath: String, limit: Int = 100) async throws -> [GitCommit] {
        // Format: Hash|Message|Author|UnixTimestamp
        let output = try await executeGit(args: ["log", "-n", "\(limit)", "--pretty=format:%H|%s|%an|%at"], in: repositoryPath)
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        return lines.compactMap { line -> GitCommit? in
            let parts = line.components(separatedBy: "|")
            guard parts.count >= 4, let timestamp = TimeInterval(parts[3]) else { return nil }
            let date = Date(timeIntervalSince1970: timestamp)
            return GitCommit(id: parts[0], message: parts[1], author: parts[2], date: date)
        }
    }
    
    public func commit(message: String, in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["commit", "-m", message], in: repositoryPath)
    }
    
    public func stage(files: [String], in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["add"] + files, in: repositoryPath)
    }
    
    public func unstage(files: [String], in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["restore", "--staged"] + files, in: repositoryPath)
    }
    
    public func checkout(branch: String, in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["checkout", branch], in: repositoryPath)
    }
    
    public func createBranch(name: String, in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["checkout", "-b", name], in: repositoryPath)
    }
    
    public func push(in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["push"], in: repositoryPath)
    }
    
    public func pull(in repositoryPath: String) async throws {
        _ = try await executeGit(args: ["pull"], in: repositoryPath)
    }
}
