import SwiftUI
import WebKit
import Core
import UIComponents

public struct MarkdownWorkspaceView: View {
    @State private var viewModel: MarkdownViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: MarkdownViewModel = MarkdownViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            HStack(spacing: 0) {
                // Editor
                TextEditor(text: $viewModel.markdownText)
                    .font(DesignSystem.Typography.code)
                    .padding()
                    .background(theme.background)
                    .scrollContentBackground(.hidden)
                
                Divider()
                
                // Live Preview
                WebView(htmlContent: viewModel.htmlContent)
                    .background(theme.secondaryBackground)
            }
            
            Divider().background(theme.secondaryText.opacity(0.3))
            footerView
        }
    }
    
    private var toolbarView: some View {
        HStack {
            Text("Markdown Workspace")
                .font(DesignSystem.Typography.subHeader)
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            Button("Export HTML") {
                viewModel.exportToHTML()
            }
            .buttonStyle(.nova)
            
            Button("Export PDF") {
                viewModel.exportToPDF()
            }
            .buttonStyle(.nova)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(theme.secondaryBackground)
    }
    
    private var footerView: some View {
        HStack {
            Text("\(viewModel.wordCount) Words")
            Spacer()
            Text("\(viewModel.readingTime) Min Read")
        }
        .font(DesignSystem.Typography.caption)
        .foregroundColor(theme.secondaryText)
        .padding(DesignSystem.Spacing.small)
        .background(theme.secondaryBackground)
    }
}

/// A simple SwiftUI wrapper for WKWebView to display rendered HTML.
#if os(macOS)
struct WebView: NSViewRepresentable {
    let htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground") // Transparent background
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#else
// Fallback for previews or iOS builds if used
struct WebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif
