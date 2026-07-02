# AI Provider Architecture

```mermaid
graph TD
    UI[AIWorkspaceView] --> VM[AIViewModel]
    VM --> Protocol[AIProviderProtocol]
    
    Protocol <|-- OpenAI[OpenAIProvider]
    Protocol <|-- Ollama[OllamaProvider]
    
    OpenAI --> REST_SSE[OpenAI API (SSE Stream)]
    Ollama --> REST_JSON[Ollama Local (JSON Stream)]
    
    VM --> DB[SwiftData Context]
    DB --> Models[AIConversation & AIMessage]
```
