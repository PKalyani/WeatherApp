//
//  KeychainHelper.swift
//  WeatherApp
//
//  Created by Kalyani Puvvada on 5/21/23.
//

import Foundation

// Saving, fetching and deleting search text from keychain
class KeychainHelper {
    static let shared = KeychainHelper()
    
    func saveText(searchText: String, searchKey: String) {
        let value = searchText.data(using: .utf8)!

        // Set attributes
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: searchKey,
            kSecValueData as String: value,
        ]
        
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("User saved successfully in the keychain")
        } else {
            print("Something went wrong trying to save the user in the keychain")
        }
    }
    
    func deleteText(searchKey: String) {
        let searchKey = "MySearch"
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: searchKey,
        ]

        if SecItemDelete(query as CFDictionary) == noErr {
            print("User removed successfully from the keychain")
        } else {
            print("Something went wrong trying to remove the user from the keychain")
        }
    }
    
    func fetchText(searchText: String) -> String? {
        let searchKey = "MySearch"

        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: searchKey,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let searchKey = existingItem[kSecAttrAccount as String] as? String,
               let valueData = existingItem[kSecValueData as String] as? Data,
               let value = String(data: valueData, encoding: .utf8)
            {
                print(searchKey)
                print(value)
                return value
            }
        }
        return ""
    }
}
