import SwiftUI
import Charts
import Core
import UIComponents

public struct SystemMonitorView: View {
    @State private var viewModel: SystemMonitorViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: SystemMonitorViewModel = SystemMonitorViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    HStack(spacing: DesignSystem.Spacing.large) {
                        metricCard(title: "CPU Usage", value: String(format: "%.1f%%", viewModel.currentCPU), color: theme.accent) {
                            Chart(viewModel.cpuHistory) { item in
                                LineMark(
                                    x: .value("Time", item.date),
                                    y: .value("Usage", item.value)
                                )
                                .foregroundStyle(theme.accent)
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        
                        metricCard(title: "Memory Usage", value: String(format: "%.1f%%", viewModel.currentMemory), color: theme.warning) {
                            Chart(viewModel.memoryHistory) { item in
                                LineMark(
                                    x: .value("Time", item.date),
                                    y: .value("Usage", item.value)
                                )
                                .foregroundStyle(theme.warning)
                                .interpolationMethod(.catmullRom)
                            }
                        }
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.large) {
                        let usedDisk = viewModel.totalDisk - viewModel.freeDisk
                        let diskPercent = Double(usedDisk) / Double(max(viewModel.totalDisk, 1)) * 100
                        metricCard(title: "Disk Usage", value: String(format: "%.1f%%", diskPercent), color: theme.error) {
                            ProgressView(value: diskPercent, total: 100)
                                .progressViewStyle(.linear)
                                .tint(theme.error)
                            HStack {
                                Text("\(formatBytes(usedDisk)) Used")
                                Spacer()
                                Text("\(formatBytes(viewModel.totalDisk)) Total")
                            }
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(theme.secondaryText)
                            .padding(.top, 4)
                        }
                        
                        metricCard(title: "System Stats", value: "", color: theme.success) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Running Processes:")
                                    Spacer()
                                    Text("\(viewModel.runningProcessesCount)")
                                }
                                HStack {
                                    Text("GPU Status:")
                                    Spacer()
                                    Text("Active (Integrated)")
                                }
                                HStack {
                                    Text("Network:")
                                    Spacer()
                                    Text("Connected")
                                }
                            }
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(theme.secondaryText)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.large)
            }
        }
        .background(theme.background)
    }
    
    private var toolbarView: some View {
        HStack {
            Text("System Monitor")
                .font(DesignSystem.Typography.subHeader)
                .foregroundColor(theme.primaryText)
            Spacer()
            // Status Indicator
            HStack(spacing: 6) {
                Circle().fill(theme.success).frame(width: 8, height: 8)
                Text("Live Updating")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(theme.secondaryText)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(theme.secondaryBackground)
    }
    
    @ViewBuilder
    private func metricCard<Content: View>(title: String, value: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.subHeader)
                    .foregroundColor(theme.primaryText)
                Spacer()
                Text(value)
                    .font(DesignSystem.Typography.header)
                    .foregroundColor(color)
            }
            
            content()
                .frame(height: 100)
        }
        .padding()
        .background(theme.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
