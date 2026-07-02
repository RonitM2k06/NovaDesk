import SwiftUI
import Core
import UIComponents

public struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: DashboardViewModel = DashboardViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                headerView
                
                // Using LazyVGrid for responsive widget layout
                let columns = [
                    GridItem(.adaptive(minimum: 300, maximum: 600), spacing: DesignSystem.Spacing.large)
                ]
                
                LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.large) {
                    // For drag and drop in Phase 2, we use standard reordering logic on a list or grid
                    // In SwiftUI, GridItem reordering requires specialized drag gestures.
                    // For now, we render the widgets in their positionIndex order.
                    ForEach(viewModel.widgets) { widget in
                        WidgetContainer(
                            widget: widget, 
                            metrics: viewModel.currentMetrics,
                            isEditMode: viewModel.isEditMode,
                            onResize: { size in
                                viewModel.resizeWidget(widget, to: size)
                            }
                        )
                    }
                }
            }
            .padding(DesignSystem.Spacing.xLarge)
        }
        .background(theme.secondaryBackground)
        .onAppear {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Dashboard")
                    .font(DesignSystem.Typography.header)
                    .foregroundColor(theme.primaryText)
                Text("Welcome back to your workspace.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(theme.secondaryText)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.toggleEditMode()
                }
            }) {
                Text(viewModel.isEditMode ? "Done" : "Edit Layout")
            }
            .buttonStyle(.nova)
        }
    }
}

/// A container view that frames individual widgets
struct WidgetContainer: View {
    let widget: DashboardWidget
    let metrics: SystemMetrics
    let isEditMode: Bool
    let onResize: (WidgetSize) -> Void
    
    @Environment(\.themePalette) private var theme
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(widget.type.rawValue)
                    .font(DesignSystem.Typography.subHeader)
                    .foregroundColor(theme.primaryText)
                Spacer()
                if isEditMode {
                    Menu {
                        Button("Small") { onResize(.small) }
                        Button("Medium") { onResize(.medium) }
                        Button("Large") { onResize(.large) }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(theme.secondaryText)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            .padding([.horizontal, .top], DesignSystem.Spacing.medium)
            
            Divider().background(theme.secondaryText.opacity(0.3))
            
            // Widget Content
            Group {
                switch widget.type {
                case .systemMonitor:
                    SystemMonitorWidget(metrics: metrics)
                case .recentProjects:
                    Text("Project List Placeholder").foregroundColor(theme.secondaryText)
                case .recentNotes:
                    Text("Notes List Placeholder").foregroundColor(theme.secondaryText)
                case .gitActivity:
                    Text("Git Graph Placeholder").foregroundColor(theme.secondaryText)
                case .quickActions:
                    Text("Quick Actions Placeholder").foregroundColor(theme.secondaryText)
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: heightForSize(widget.size))
        .background(theme.background)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private func heightForSize(_ size: WidgetSize) -> CGFloat {
        switch size {
        case .small: return 200
        case .medium: return 250
        case .large: return 400
        }
    }
}

struct SystemMonitorWidget: View {
    let metrics: SystemMetrics
    @Environment(\.themePalette) private var theme
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            MetricRow(title: "CPU", value: metrics.cpuUsage, color: theme.accent)
            MetricRow(title: "Memory", value: metrics.memoryUsage, color: theme.warning)
            MetricRow(title: "Disk", value: metrics.diskUsage, color: theme.success)
        }
    }
}

struct MetricRow: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value * 100))%")
            }
            .font(DesignSystem.Typography.caption)
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: proxy.size.width * CGFloat(value), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
