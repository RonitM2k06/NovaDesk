import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class TerminalViewModel {
    private let terminalService: TerminalServiceProtocol
    
    public var tabs: [TerminalTab] = []
    public var activeTabId: UUID?
    
    public var activeTab: TerminalTab? {
        get { tabs.first(where: { $0.id == activeTabId }) }
        set {
            if let newValue = newValue, let index = tabs.firstIndex(where: { $0.id == newValue.id }) {
                tabs[index] = newValue
            }
        }
    }
    
    public init(terminalService: TerminalServiceProtocol = LocalTerminalService()) {
        self.terminalService = terminalService
        createNewTab()
    }
    
    public func createNewTab() {
        let profile = terminalService.defaultProfile()
        let session = TerminalSession(profile: profile)
        let tab = TerminalTab(title: "Terminal", sessions: [session], activeSessionId: session.id)
        
        tabs.append(tab)
        activeTabId = tab.id
    }
    
    public func closeTab(id: UUID) {
        tabs.removeAll { $0.id == id }
        if activeTabId == id {
            activeTabId = tabs.last?.id
        }
    }
    
    public func splitActiveTab() {
        guard let tabId = activeTabId, let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        
        let profile = terminalService.defaultProfile()
        let session = TerminalSession(profile: profile)
        
        tabs[tabIndex].sessions.append(session)
        tabs[tabIndex].activeSessionId = session.id
    }
    
    public func closeActiveSessionInTab() {
        guard let tabId = activeTabId, let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        guard let sessionId = tabs[tabIndex].activeSessionId else { return }
        
        tabs[tabIndex].sessions.removeAll { $0.id == sessionId }
        tabs[tabIndex].activeSessionId = tabs[tabIndex].sessions.last?.id
        
        // Close the tab entirely if it has no sessions left
        if tabs[tabIndex].sessions.isEmpty {
            closeTab(id: tabId)
        }
    }
}
