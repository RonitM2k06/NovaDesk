import Foundation
import CoreGraphics

/// Defines the type of widget available on the dashboard.
public enum WidgetType: String, Codable, CaseIterable, Identifiable {
    case recentProjects = "Recent Projects"
    case systemMonitor = "System Monitor"
    case recentNotes = "Recent Notes"
    case gitActivity = "Git Activity"
    case quickActions = "Quick Actions"
    
    public var id: String { self.rawValue }
}

/// Defines the size class of a widget.
public enum WidgetSize: String, Codable {
    case small
    case medium
    case large
    
    public var dimensions: (columns: Int, rows: Int) {
        switch self {
        case .small: return (1, 1)
        case .medium: return (2, 1)
        case .large: return (2, 2)
        }
    }
}

/// Represents a widget's instance on the dashboard.
public struct DashboardWidget: Codable, Identifiable, Equatable {
    public let id: UUID
    public let type: WidgetType
    public var size: WidgetSize
    public var positionIndex: Int // Defines ordering/layout
    
    public init(id: UUID = UUID(), type: WidgetType, size: WidgetSize, positionIndex: Int) {
        self.id = id
        self.type = type
        self.size = size
        self.positionIndex = positionIndex
    }
}

/// Protocol for persisting dashboard layout.
public protocol DashboardLayoutServiceProtocol {
    func loadLayout() -> [DashboardWidget]
    func saveLayout(_ widgets: [DashboardWidget]) throws
}

public final class UserDefaultsDashboardLayoutService: DashboardLayoutServiceProtocol {
    private let defaults = UserDefaults.standard
    private let layoutKey = "com.ronitmongia.NovaDesk.DashboardLayout"
    
    public init() {}
    
    public func loadLayout() -> [DashboardWidget] {
        if let data = defaults.data(forKey: layoutKey),
           let widgets = try? JSONDecoder().decode([DashboardWidget].self, from: data) {
            return widgets.sorted(by: { $0.positionIndex < $1.positionIndex })
        }
        // Default layout
        return [
            DashboardWidget(type: .quickActions, size: .small, positionIndex: 0),
            DashboardWidget(type: .systemMonitor, size: .medium, positionIndex: 1),
            DashboardWidget(type: .recentProjects, size: .large, positionIndex: 2),
            DashboardWidget(type: .recentNotes, size: .medium, positionIndex: 3)
        ]
    }
    
    public func saveLayout(_ widgets: [DashboardWidget]) throws {
        let encoded = try JSONEncoder().encode(widgets)
        defaults.set(encoded, forKey: layoutKey)
    }
}
