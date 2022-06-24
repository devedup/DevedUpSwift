//  JSONLoader
//  Created by David Casserly on 01/02/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.

import Foundation

public class JSONLoader {
    
    public static func dictionary(forPath path: String) -> [String:AnyObject]? {
        guard let data = self.data(forPath: path) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        } catch {
            print("Couldn't decode \(error)")
        }
        return nil
    }
    
    public static func string(forPath path: String) -> String? {
        let dictionary = self.dictionary(forPath: path)
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary as Any, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Couldn't decode \(error)")
        }
        return nil
    }
    
    public static func data(forPath path: String, bundle: Bundle = .main) -> Data? {
        guard let path = bundle.path(forResource: path, ofType: "json") else {
            return nil
        }
        let filePath = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: filePath)
            return data
        } catch {
            preconditionFailure("Error parsing data \(error)")
        }
    }
    
    public static func load<T:Decodable>(forPath path: String, bundle: Bundle = .main) throws -> T? {
        guard let loadedData = data(forPath: path, bundle: bundle) else {
            return nil
        }
        do {
            let result = try JSONDecoder().decode(T.self, from: loadedData)
            return result
        } catch {
            print(error)
            return nil
        }        
    }
    
    @available(*, deprecated, message: "Use loadJSON which throws errors. This doesn't and hides them. ")
    public static func load<T:Decodable>(fromJSON string: String) -> T? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print(error)
            return nil
        }
    }
        
    public static func loadJSON<T:Decodable>(fromJSON string: String) throws -> T {
        guard let data = string.data(using: .utf8) else {
            throw FoundationError.JSONParsingError(parseError: "Could turn string into data using .utf8", error: nil)
        }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw FoundationError.JSONParsingError(parseError: "Could not parse JSON", error: error)
        }
    }
    
    public static func loadJSON<T:Decodable>(fromJSONData data: Data) throws -> T {
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw FoundationError.JSONParsingError(parseError: "Could not parse JSON", error: error)
        }
    }
    
}
 
