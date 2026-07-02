import Foundation
#if os(macOS)
import Security
#endif

public protocol KeychainServiceProtocol {
    func save(token: String, for account: String) throws
    func retrieve(for account: String) throws -> String?
    func delete(for account: String) throws
}

public enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
}

public final class MacOSKeychainService: KeychainServiceProtocol {
    private let serviceName = "com.ronitmongia.NovaDesk.GitHubToken"
    
    public init() {}
    
    public func save(token: String, for account: String) throws {
        #if os(macOS)
        let tokenData = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecValueData as String: tokenData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
        #endif
    }
    
    public func retrieve(for account: String) throws -> String? {
        #if os(macOS)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            return String(data: retrievedData, encoding: .utf8)
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError.unknown(status)
        }
        #else
        return nil
        #endif
    }
    
    public func delete(for account: String) throws {
        #if os(macOS)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unknown(status)
        }
        #endif
    }
}
