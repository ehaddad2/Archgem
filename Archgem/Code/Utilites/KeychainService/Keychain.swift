import Foundation
import Security
/*
 a very simple generic class for retrieving user specific sensitive data
 */

class KeychainService {
    enum KeychainError: Error {
        case noData
        case unexpectedData
        case unhandledError(status: OSStatus)
        // add any other custom errors you need
    }
    class func addEntry(id: String, data: String)-> OSStatus {
        let keychainItem = [
          kSecValueData: data.data(using: .utf8)!,
          kSecAttrAccount: id,
          kSecAttrServer: "Host".localized,
          kSecClass: kSecClassInternetPassword,
        ] as CFDictionary
        let status = SecItemAdd(keychainItem, nil)
        
        if (status != 0) {
            print("WARNING: cannot add entry to keychain, possibly existing one present")
        }
        return status
    }
    
    class func getEntry(id: String) throws -> CFTypeRef? {
        let query: [String:Any] = [
          kSecClass as String: kSecClassInternetPassword,
          kSecAttrServer as String: "Host".localized,
          kSecReturnAttributes as String: true,
          kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noData}
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        return item
    }
    
    class func updateEntry(id: String, data: String) -> OSStatus {
        let query = [
          kSecClass: kSecClassInternetPassword,
          kSecAttrServer: "Host".localized,
          kSecAttrAccount: id
        ] as CFDictionary

        let updateFields = [
          kSecValueData: data.data(using: .utf8)!
        ] as CFDictionary

        let status = SecItemUpdate(query, updateFields)
        
        return status
    }
    
    class func deleteEntry(id: String) -> OSStatus {
        let query = [
          kSecClass: kSecClassInternetPassword,
          kSecAttrServer: "Host".localized,
          kSecAttrAccount: id
        ] as CFDictionary

        let status = SecItemDelete(query)
        
        return status
    }
    
}

