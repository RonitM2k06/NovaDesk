import Foundation
import SwiftData
import Core

@MainActor
@Observable
public final class AIViewModel {
    private let context: ModelContext
    private let keychainService: KeychainServiceProtocol
    private var provider: AIProviderProtocol?
    
    public var conversations: [AIConversation] = []
    public var selectedConversation: AIConversation? {
        didSet { loadMessages() }
    }
    
    public var currentMessages: [AIMessage] = []
    public var inputText: String = ""
    public var isGenerating: Bool = false
    public var currentStreamingResponse: String = ""
    public var errorMessage: String? = nil
    
    public var selectedProvider: String = "OpenAI" {
        didSet { updateProvider() }
    }
    
    private var generationTask: Task<Void, Never>?
    
    public init(
        context: ModelContext = PersistenceController.shared.mainContext,
        keychainService: KeychainServiceProtocol = DependencyContainer.shared.resolve(KeychainServiceProtocol.self)
    ) {
        self.context = context
        self.keychainService = keychainService
        loadConversations()
        updateProvider()
    }
    
    private func updateProvider() {
        if selectedProvider == "Ollama" {
            provider = OllamaProvider()
        } else {
            if let token = try? keychainService.retrieve(for: "openai_api_key") {
                provider = OpenAIProvider(apiKey: token)
            } else {
                provider = nil // Requires configuration
            }
        }
    }
    
    public func loadConversations() {
        let descriptor = FetchDescriptor<AIConversation>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        do {
            conversations = try context.fetch(descriptor)
            if selectedConversation == nil {
                selectedConversation = conversations.first
            }
        } catch {
            errorMessage = "Failed to load conversations."
        }
    }
    
    public func loadMessages() {
        guard let conversation = selectedConversation else {
            currentMessages = []
            return
        }
        let convId = conversation.id
        let descriptor = FetchDescriptor<AIMessage>(
            predicate: #Predicate { $0.conversation?.id == convId },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        do {
            currentMessages = try context.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load messages."
        }
    }
    
    public func createConversation() {
        let newConv = AIConversation(title: "New Conversation")
        context.insert(newConv)
        try? context.save()
        loadConversations()
        selectedConversation = newConv
    }
    
    public func deleteConversation(_ conv: AIConversation) {
        context.delete(conv)
        try? context.save()
        if selectedConversation?.id == conv.id {
            selectedConversation = nil
        }
        loadConversations()
    }
    
    public func sendMessage() {
        guard !inputText.isEmpty, let provider = provider, let conv = selectedConversation else {
            if self.provider == nil {
                errorMessage = "Provider not configured. Please add an API key."
            }
            return
        }
        
        let userText = inputText
        inputText = ""
        errorMessage = nil
        isGenerating = true
        currentStreamingResponse = ""
        
        let userMessage = AIMessage(role: .user, content: userText, conversation: conv)
        context.insert(userMessage)
        try? context.save()
        loadMessages()
        
        // Ensure conversation title is updated if it's the first message
        if currentMessages.count == 1 {
            conv.title = String(userText.prefix(30))
        }
        conv.updatedAt = Date()
        
        let history = currentMessages
        let contextString = "Context: No active project context provided." // Simulated ContextManager injection
        
        generationTask = Task {
            do {
                let stream = try await provider.sendMessageStream(userText, history: history, context: contextString)
                for try await token in stream {
                    if Task.isCancelled { break }
                    self.currentStreamingResponse += token
                }
                
                guard !Task.isCancelled else { return }
                
                // Save assistant message
                let assistantMessage = AIMessage(role: .assistant, content: self.currentStreamingResponse, conversation: conv)
                self.context.insert(assistantMessage)
                try? self.context.save()
                
                self.currentStreamingResponse = ""
                self.loadMessages()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isGenerating = false
        }
    }
    
    public func cancelGeneration() {
        generationTask?.cancel()
        isGenerating = false
        
        if !currentStreamingResponse.isEmpty, let conv = selectedConversation {
            let partialMessage = AIMessage(role: .assistant, content: currentStreamingResponse + "\n\n*(Cancelled)*", conversation: conv)
            context.insert(partialMessage)
            try? context.save()
            currentStreamingResponse = ""
            loadMessages()
        }
    }
}
