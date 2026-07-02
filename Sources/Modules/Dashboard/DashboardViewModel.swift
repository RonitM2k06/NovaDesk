import SwiftUI
import Core
import Observation

@MainActor
@Observable
public final class DashboardViewModel {
    private let layoutService: DashboardLayoutServiceProtocol
    private let systemInfoService: SystemInformationServiceProtocol
    
    public var widgets: [DashboardWidget] = []
    public var currentMetrics: SystemMetrics = SystemMetrics()
    public var isEditMode: Bool = false
    
    // Polling task
    private var pollingTask: Task<Void, Never>?
    
    public init(
        layoutService: DashboardLayoutServiceProtocol = DependencyContainer.shared.resolve(DashboardLayoutServiceProtocol.self),
        systemInfoService: SystemInformationServiceProtocol = DependencyContainer.shared.resolve(SystemInformationServiceProtocol.self)
    ) {
        self.layoutService = layoutService
        self.systemInfoService = systemInfoService
        self.widgets = layoutService.loadLayout()
    }
    
    public func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let metrics = try await systemInfoService.fetchCurrentMetrics()
                    self.currentMetrics = metrics
                } catch {
                    // Log error
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
    }
    
    public func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    public func toggleEditMode() {
        isEditMode.toggle()
        if !isEditMode {
            saveLayout()
        }
    }
    
    public func moveWidget(from source: IndexSet, to destination: Int) {
        widgets.move(fromOffsets: source, toOffset: destination)
        // Update position indices
        for (index, widget) in widgets.enumerated() {
            var updatedWidget = widget
            updatedWidget.positionIndex = index
            widgets[index] = updatedWidget
        }
    }
    
    public func resizeWidget(_ widget: DashboardWidget, to size: WidgetSize) {
        if let index = widgets.firstIndex(where: { $0.id == widget.id }) {
            widgets[index].size = size
        }
    }
    
    private func saveLayout() {
        try? layoutService.saveLayout(widgets)
    }
}
