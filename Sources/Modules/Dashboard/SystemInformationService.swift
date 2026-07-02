import Foundation

/// Represents the current system metrics.
public struct SystemMetrics: Equatable {
    public var cpuUsage: Double // 0.0 to 1.0
    public var memoryUsage: Double // 0.0 to 1.0
    public var diskUsage: Double // 0.0 to 1.0
    
    public init(cpuUsage: Double = 0, memoryUsage: Double = 0, diskUsage: Double = 0) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
    }
}

public protocol SystemInformationServiceProtocol {
    func fetchCurrentMetrics() async throws -> SystemMetrics
}

public final class MacOSSystemInformationService: SystemInformationServiceProtocol {
    public init() {}
    
    public func fetchCurrentMetrics() async throws -> SystemMetrics {
        // Native macOS API extraction
        // In a true macOS app, we would use mach host_statistics for CPU/Mem, and URL attributes for disk.
        
        let memory = getMemoryUsage()
        let disk = getDiskUsage()
        let cpu = getCPUUsage() // Usually requires calculating deltas over time
        
        return SystemMetrics(cpuUsage: cpu, memoryUsage: memory, diskUsage: disk)
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var vmStats = vm_statistics64_data_t()
        
        let kerr = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(info)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &info)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let active = Double(vmStats.active_count) * Double(vm_page_size)
            let wire = Double(vmStats.wire_count) * Double(vm_page_size)
            let totalUsed = active + wire
            let physical = Double(ProcessInfo.processInfo.physicalMemory)
            return physical > 0 ? totalUsed / physical : 0.0
        }
        return 0.0
    }
    
    private func getDiskUsage() -> Double {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            if let total = values.volumeTotalCapacity, let available = values.volumeAvailableCapacity {
                let used = Double(total - available)
                return Double(total) > 0 ? used / Double(total) : 0.0
            }
        } catch {
            // fallback
        }
        return 0.0
    }
    
    private func getCPUUsage() -> Double {
        // CPU usage requires delta calculation from host_processor_info.
        // For Phase 2, we return a mock value representing an instant reading,
        // as a true implementation requires an ongoing timer keeping previous state.
        // In a production app, we would store `previousInfo` and diff it here.
        return 0.15 // Placeholder 15% to satisfy interface until ongoing polling is added.
    }
}
