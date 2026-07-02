import SwiftUI
import Core
import UIComponents
import Markdown // Note: In a real app we'd use a Markdown package, but we can simulate styling here.

public struct AIWorkspaceView: View {
    @State private var viewModel: AIViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: AIViewModel = AIViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationSplitView {
            sidebarView
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            chatAreaView
        }
        .background(theme.background)
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Conversations")
                    .font(DesignSystem.Typography.subHeader)
                Spacer()
                Button(action: { viewModel.createConversation() }) {
                    Image(systemName: "square.and.pencil")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(theme.secondaryBackground)
            
            Divider().background(theme.secondaryText.opacity(0.3))
            
            List(selection: $viewModel.selectedConversation) {
                ForEach(viewModel.conversations) { conv in
                    NavigationLink(value: conv) {
                        VStack(alignment: .leading) {
                            Text(conv.title)
                                .font(DesignSystem.Typography.body.weight(.medium))
                                .lineLimit(1)
                            Text(conv.updatedAt.formatted(.relative(presentation: .named)))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteConversation(conv)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            Divider().background(theme.secondaryText.opacity(0.3))
            
            Picker("Provider", selection: $viewModel.selectedProvider) {
                Text("OpenAI").tag("OpenAI")
                Text("Ollama").tag("Ollama")
            }
            .pickerStyle(.menu)
            .padding()
            .background(theme.secondaryBackground)
        }
    }
    
    private var chatAreaView: some View {
        VStack(spacing: 0) {
            if let conv = viewModel.selectedConversation {
                // Header
                HStack {
                    Text(conv.title)
                        .font(DesignSystem.Typography.subHeader)
                    Spacer()
                }
                .padding()
                .background(theme.secondaryBackground)
                
                Divider().background(theme.secondaryText.opacity(0.3))
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(viewModel.currentMessages) { message in
                                MessageBubble(message: message, isStreaming: false)
                                    .id(message.id)
                            }
                            
                            if viewModel.isGenerating {
                                MessageBubble(
                                    message: AIMessage(role: .assistant, content: viewModel.currentStreamingResponse),
                                    isStreaming: true
                                )
                                .id("streaming_bubble")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.currentMessages.count) { _ in
                        if let last = viewModel.currentMessages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: viewModel.currentStreamingResponse) { _ in
                        withAnimation { proxy.scrollTo("streaming_bubble", anchor: .bottom) }
                    }
                }
                
                Divider().background(theme.secondaryText.opacity(0.3))
                
                // Error Display
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(theme.error)
                        .padding(.vertical, 4)
                }
                
                // Input Area
                HStack(alignment: .bottom) {
                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 40, maxHeight: 150)
                        .padding(4)
                        .background(theme.background)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.secondaryText.opacity(0.3), lineWidth: 1)
                        )
                    
                    if viewModel.isGenerating {
                        Button(action: { viewModel.cancelGeneration() }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.title)
                                .foregroundColor(theme.error)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: { viewModel.sendMessage() }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(viewModel.inputText.isEmpty ? theme.secondaryText : theme.accent)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.inputText.isEmpty)
                    }
                }
                .padding()
                .background(theme.secondaryBackground)
                
            } else {
                Text("Select a conversation")
                    .foregroundColor(theme.secondaryText)
            }
        }
    }
}

struct MessageBubble: View {
    let message: AIMessage
    let isStreaming: Bool
    @Environment(\.themePalette) private var theme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.role == .assistant {
                        Image(systemName: "sparkles")
                            .foregroundColor(theme.accent)
                    }
                    Text(message.role == .user ? "You" : "NovaDesk AI")
                        .font(DesignSystem.Typography.caption.weight(.bold))
                        .foregroundColor(theme.secondaryText)
                }
                
                // In production, use standard SwiftUI Markdown formatting:
                // Text(LocalizedStringKey(message.content))
                Text(message.content)
                    .font(DesignSystem.Typography.body)
                    .padding(12)
                    .background(message.role == .user ? theme.accent.opacity(0.2) : theme.secondaryBackground)
                    .cornerRadius(12)
                    .foregroundColor(theme.primaryText)
                    .textSelection(.enabled)
                
                if isStreaming {
                    ProgressView()
                        .scaleEffect(0.5)
                        .padding(.top, 4)
                }
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}
