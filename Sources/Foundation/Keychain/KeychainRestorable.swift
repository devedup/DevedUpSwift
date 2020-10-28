//
//  Restorable.swift
//  
//
//  Created by David Casserly on 13/02/2020.
//

import Foundation

public protocol KeychainRestorable {
    associatedtype CodableType: Codable
    static var restoreKey: String { get }
    func saveToKeyChain() -> Bool
    static func restoreFromKeychain() -> CodableType?
}

public extension KeychainRestorable where Self: Codable {
    
    func saveToKeyChain() -> Bool {
        do {
            let coded = try JSONEncoder().encode(self)
            if let codedString = String(data: coded, encoding: .utf8) {
                KeychainService.save(service: "DevedUpSwift", account: Self.restoreKey, data: codedString)
                return true
            } else {
                assertionFailure("Could not save \(self) to keychain") //DEBUG only
                return false
            }
        } catch {
            assertionFailure("Could not save \(self) [\(error)]") //DEBUG only
            return false 
        }
    }
    
    static func restoreFromKeychain() -> CodableType? {
        guard let string = KeychainService.load(service: "DevedUpSwift", account: Self.restoreKey),
              let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(CodableType.self, from: data)
        } catch {
            assertionFailure("Could not decode saved \(self) [\(error)]") //DEBUG only
            return nil
        }
    }
    
}

/*
 
 Example use of a struct you want to be able to save and restore
 
 struct SavedBasket: Restorable, Codable {
     
     typealias CodableType = SavedBasket
     static var restoreKey: String { "SavedBasket" }
     
     let savedItems: [ProjectID]
     
 }
 
 
 */
