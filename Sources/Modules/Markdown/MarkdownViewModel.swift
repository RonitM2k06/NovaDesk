import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class MarkdownViewModel {
    private let engine: MarkdownEngineProtocol
    
    public var markdownText: String = "# Hello Markdown\n\nStart typing here..." {
        didSet {
            updateMetrics()
            debouncedRender()
        }
    }
    
    public var htmlContent: String = ""
    public var wordCount: Int = 0
    public var readingTime: Int = 0
    public var config: MarkdownConfig = MarkdownConfig()
    
    private var renderTask: Task<Void, Never>?
    
    public init(engine: MarkdownEngineProtocol = WebMarkdownEngine()) {
        self.engine = engine
        updateMetrics()
        renderHTML()
    }
    
    private func updateMetrics() {
        wordCount = engine.calculateWordCount(for: markdownText)
        readingTime = engine.calculateReadingTime(for: wordCount)
    }
    
    private func debouncedRender() {
        renderTask?.cancel()
        renderTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            if !Task.isCancelled {
                renderHTML()
            }
        }
    }
    
    public func renderHTML() {
        htmlContent = engine.generateHTML(from: markdownText, config: config)
    }
    
    public func exportToHTML() {
        // AppKit file saving logic would go here
    }
    
    public func exportToPDF() {
        // AppKit print/PDF logic would go here
    }
}
