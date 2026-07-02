import XCTest
@testable import Core
@testable import NovaModules

final class MarkdownEngineTests: XCTestCase {
    
    var engine: MarkdownEngineProtocol!
    
    override func setUp() {
        super.setUp()
        engine = WebMarkdownEngine()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    func testWordCountCalculation() {
        let text = "This is a simple test. It has exactly ten words."
        let count = engine.calculateWordCount(for: text)
        XCTAssertEqual(count, 10, "Word count should correctly strip punctuation and count words.")
    }
    
    func testReadingTimeCalculation() {
        let count = 450
        let time = engine.calculateReadingTime(for: count)
        XCTAssertEqual(time, 3, "Reading time for 450 words at 200wpm should ceil to 3 minutes.")
    }
    
    func testHTMLGenerationContainsScriptsWhenConfigured() {
        let config = MarkdownConfig(enableMermaid: true, enableMath: true, enableSyntaxHighlighting: true)
        let html = engine.generateHTML(from: "# Test", config: config)
        
        XCTAssertTrue(html.contains("mermaid.min.js"), "HTML should contain Mermaid JS when enabled.")
        XCTAssertTrue(html.contains("mathjax"), "HTML should contain MathJax when enabled.")
        XCTAssertTrue(html.contains("highlight.min.js"), "HTML should contain Highlight JS when enabled.")
    }
}
