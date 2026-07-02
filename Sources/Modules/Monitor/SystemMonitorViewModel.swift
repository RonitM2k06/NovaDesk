import SwiftUI
import Core
import Observation
import Charts

@MainActor
@Observable
public final class SystemMonitorViewModel {
    private let systemInfoService: SystemInformationServiceProtocol
    
    public struct ChartDataPoint: Identifiable {
        public let id = UUID()
        public let date: Date
        public let value: Double
    }
    
    public var cpuHistory: [ChartDataPoint] = []
    public var memoryHistory: [ChartDataPoint] = []
    
    public var currentCPU: Double = 0
    public var currentMemory: Double = 0
    public var freeDisk: Int64 = 0
    public var totalDisk: Int64 = 0
    
    // In a real macOS app, processes would be fetched via `ps` or `proc_pidinfo`
    public var runningProcessesCount: Int = 0 
    
    private var timerTask: Task<Void, Never>?
    
    public init(systemInfoService: SystemInformationServiceProtocol = MacOSSystemInformationService()) {
        self.systemInfoService = systemInfoService
        startPolling()
    }
    
    deinit {
        timerTask?.cancel()
    }
    
    public func startPolling() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                await fetchMetrics()
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
    }
    
    private func fetchMetrics() async {
        do {
            let cpu = try await systemInfoService.getCPUUsage()
            let mem = try await systemInfoService.getMemoryUsage()
            let disk = try await systemInfoService.getDiskUsage()
            
            self.currentCPU = cpu
            self.currentMemory = Double(mem.used) / Double(max(mem.total, 1)) * 100.0
            
            self.freeDisk = disk.free
            self.totalDisk = disk.total
            
            // Mock running process count for architectural representation
            self.runningProcessesCount = 342 
            
            let now = Date()
            cpuHistory.append(ChartDataPoint(date: now, value: self.currentCPU))
            memoryHistory.append(ChartDataPoint(date: now, value: self.currentMemory))
            
            // Keep last 30 data points
            if cpuHistory.count > 30 {
                cpuHistory.removeFirst(cpuHistory.count - 30)
                memoryHistory.removeFirst(memoryHistory.count - 30)
            }
        } catch {
            // Handle error silently in monitor
        }
    }
}
