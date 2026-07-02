import Foundation
import Core

public protocol AIProviderProtocol {
    func sendMessageStream(_ message: String, history: [AIMessage], context: String?) async throws -> AsyncThrowingStream<String, Error>
}

public enum AIProviderError: Error, LocalizedError {
    case invalidURL
    case missingToken
    case requestFailed(statusCode: Int)
    case decodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .missingToken: return "Missing API Token."
        case .requestFailed(let code): return "API Request Failed (HTTP \(code))."
        case .decodingFailed: return "Failed to decode response."
        }
    }
}

public final class OpenAIProvider: AIProviderProtocol {
    private let apiKey: String
    private let session = URLSession.shared
    private let model = "gpt-4-turbo"
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func sendMessageStream(_ message: String, history: [AIMessage], context: String?) async throws -> AsyncThrowingStream<String, Error> {
        guard !apiKey.isEmpty else { throw AIProviderError.missingToken }
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw AIProviderError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var messagesArray: [[String: String]] = []
        
        // System Context
        if let context = context {
            messagesArray.append(["role": "system", "content": context])
        } else {
            messagesArray.append(["role": "system", "content": "You are NovaDesk AI, an elite pair programming assistant built into a native macOS workspace."])
        }
        
        // History
        for msg in history {
            messagesArray.append(["role": msg.roleString, "content": msg.content])
        }
        
        // Current Message
        messagesArray.append(["role": "user", "content": message])
        
        let body: [String: Any] = [
            "model": model,
            "messages": messagesArray,
            "stream": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (bytes, response) = try await session.bytes(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AIProviderError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in bytes.lines {
                        if line.hasPrefix("data: "), line != "data: [DONE]" {
                            let jsonString = String(line.dropFirst(6))
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

public final class OllamaProvider: AIProviderProtocol {
    private let baseURL = "http://localhost:11434"
    private let session = URLSession.shared
    private let model = "llama3"
    
    public init() {}
    
    public func sendMessageStream(_ message: String, history: [AIMessage], context: String?) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "\(baseURL)/api/chat") else { throw AIProviderError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var messagesArray: [[String: String]] = []
        if let context = context {
            messagesArray.append(["role": "system", "content": context])
        }
        for msg in history {
            messagesArray.append(["role": msg.roleString, "content": msg.content])
        }
        messagesArray.append(["role": "user", "content": message])
        
        let body: [String: Any] = [
            "model": model,
            "messages": messagesArray,
            "stream": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (bytes, response) = try await session.bytes(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AIProviderError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in bytes.lines {
                        if let data = line.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let messageObj = json["message"] as? [String: Any],
                           let content = messageObj["content"] as? String {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
