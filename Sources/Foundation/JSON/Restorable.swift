//
//  Restorable.swift
//  
//
//  Created by David Casserly on 13/02/2020.
//

import Foundation

public protocol Restorable {
    associatedtype CodableType: Codable
    static var restoreKey: String { get }
    func save()
    static func restore() -> CodableType?
}

public extension Restorable where Self: Codable {
    
    func save() {
        do {
            let coded = try JSONEncoder().encode(self)
            UserDefaults.standard.set(coded, forKey: Self.restoreKey)
            UserDefaults.standard.synchronize()
        } catch {
            assertionFailure("Could not save \(self) [\(error)]") //DEBUG only
        }
    }
    
    static func restore() -> CodableType? {
        guard let data = UserDefaults.standard.value(forKey: Self.restoreKey) as? Data else {
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
