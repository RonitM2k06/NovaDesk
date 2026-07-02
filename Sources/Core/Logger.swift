import Foundation
import os

/// A protocol defining the logging capabilities for NovaDesk.
public protocol LoggerProtocol {
    func debug(_ message: String, category: LogCategory)
    func info(_ message: String, category: LogCategory)
    func warning(_ message: String, category: LogCategory)
    func error(_ message: String, category: LogCategory)
    func critical(_ message: String, category: LogCategory)
}

/// Categories for organizing log messages.
public enum LogCategory: String {
    case general = "General"
    case network = "Network"
    case database = "Database"
    case git = "Git"
    case ai = "AI"
    case terminal = "Terminal"
    case ui = "UI"
}

/// The concrete implementation of the Logger using Apple's unified logging system (`os.Logger`).
public struct NovaLogger: LoggerProtocol {
    private let subsystem: String
    
    // Cache of os.Logger instances by category
    private var loggers: [String: os.Logger] = [:]
    private let lock = NSLock()
    
    public init(subsystem: String = "com.ronitmongia.NovaDesk") {
        self.subsystem = subsystem
    }
    
    private mutating func getLogger(for category: LogCategory) -> os.Logger {
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = loggers[category.rawValue] {
            return existing
        }
        
        let newLogger = os.Logger(subsystem: subsystem, category: category.rawValue)
        loggers[category.rawValue] = newLogger
        return newLogger
    }
    
    public mutating func debug(_ message: String, category: LogCategory) {
        getLogger(for: category).debug("\(message, privacy: .public)")
    }
    
    public mutating func info(_ message: String, category: LogCategory) {
        getLogger(for: category).info("\(message, privacy: .public)")
    }
    
    public mutating func warning(_ message: String, category: LogCategory) {
        getLogger(for: category).warning("\(message, privacy: .public)")
    }
    
    public mutating func error(_ message: String, category: LogCategory) {
        getLogger(for: category).error("\(message, privacy: .public)")
    }
    
    public mutating func critical(_ message: String, category: LogCategory) {
        getLogger(for: category).critical("\(message, privacy: .public)")
    }
}
