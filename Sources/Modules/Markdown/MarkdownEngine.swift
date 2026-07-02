import Foundation

public struct MarkdownConfig {
    public var enableMermaid: Bool
    public var enableMath: Bool
    public var enableSyntaxHighlighting: Bool
    
    public init(enableMermaid: Bool = true, enableMath: Bool = true, enableSyntaxHighlighting: Bool = true) {
        self.enableMermaid = enableMermaid
        self.enableMath = enableMath
        self.enableSyntaxHighlighting = enableSyntaxHighlighting
    }
}

public protocol MarkdownEngineProtocol {
    func generateHTML(from markdown: String, config: MarkdownConfig) -> String
    func calculateWordCount(for text: String) -> Int
    func calculateReadingTime(for wordCount: Int) -> Int // in minutes
}

public final class WebMarkdownEngine: MarkdownEngineProtocol {
    
    public init() {}
    
    public func generateHTML(from markdown: String, config: MarkdownConfig) -> String {
        // In a true production app, we would use a robust parser like markdown-it or Swiftdown.
        // For this Phase 2 native shell, we will construct an HTML wrapper that relies on 
        // a lightweight JS library (like marked.js) to do the client-side parsing inside the WebView.
        
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let mermaidScript = config.enableMermaid ? """
        <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
        <script>mermaid.initialize({startOnLoad:true});</script>
        """ : ""
        
        let mathScript = config.enableMath ? """
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        """ : ""
        
        let highlightScript = config.enableSyntaxHighlighting ? """
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/github-dark.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js"></script>
        """ : ""
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.6;
                    padding: 20px;
                    color: #c9d1d9;
                    background-color: #0d1117;
                }
                pre { background: #161b22; padding: 16px; border-radius: 6px; overflow: auto; }
                code { font-family: ui-monospace, SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace; }
                table { border-collapse: collapse; width: 100%; margin-bottom: 16px; }
                th, td { border: 1px solid #30363d; padding: 8px; text-align: left; }
                th { background-color: #161b22; }
                img { max-width: 100%; height: auto; }
            </style>
            \(highlightScript)
            \(mathScript)
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
        </head>
        <body>
            <div id="content"></div>
            \(mermaidScript)
            <script>
                const rawMarkdown = `\(escapedMarkdown)`;
                document.getElementById('content').innerHTML = marked.parse(rawMarkdown);
                
                // Initialize HighlightJS
                if (typeof hljs !== 'undefined') {
                    document.querySelectorAll('pre code').forEach((el) => {
                        hljs.highlightElement(el);
                    });
                }
            </script>
        </body>
        </html>
        """
        return html
    }
    
    public func calculateWordCount(for text: String) -> Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        return components.filter { !$0.isEmpty }.count
    }
    
    public func calculateReadingTime(for wordCount: Int) -> Int {
        // Average reading speed is roughly 200-250 words per minute.
        return max(1, Int(ceil(Double(wordCount) / 200.0)))
    }
}
