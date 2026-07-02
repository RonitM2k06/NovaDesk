import Foundation
import os

/// A simple, protocol-oriented Dependency Injection container.
/// It uses a singleton internally to store instances but provides a clean interface for registering and resolving dependencies.
public protocol DependencyContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
    
    // Scoped registration
    func registerSingleton<T>(_ type: T.Type, instance: T)
}

public final class DependencyContainer: DependencyContainerProtocol {
    public static let shared = DependencyContainer()
    
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.lock()
        defer { lock.unlock() }
        let key = String(describing: type)
        factories[key] = factory
    }
    
    public func registerSingleton<T>(_ type: T.Type, instance: T) {
        lock.lock()
        defer { lock.unlock() }
        let key = String(describing: type)
        singletons[key] = instance
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        lock.lock()
        defer { lock.unlock() }
        
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        guard let factory = factories[key] else {
            fatalError("Dependency not registered for type: \(key)")
        }
        
        guard let instance = factory() as? T else {
            fatalError("Could not resolve dependency of type: \(key)")
        }
        
        return instance
    }
}

/// Property wrapper for injecting dependencies into ViewModels and Services.
@propertyWrapper
public struct Inject<T> {
    public let wrappedValue: T
    
    public init() {
        self.wrappedValue = DependencyContainer.shared.resolve(T.self)
    }
}
