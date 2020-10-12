//  JSONLoader
//  Created by David Casserly on 01/02/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.

import Foundation

public class JSONLoader {
    
    public static func dictionary(forPath path: String) -> [String:AnyObject]? {
        let data = self.data(forPath: path)
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
    
    public static func data(forPath path: String) -> Data {
        let testBundle = Bundle.main
        let path = testBundle.path(forResource: path, ofType: "json")
        let filePath = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: filePath)
            return data
        } catch {
            preconditionFailure("Error parsing data \(error)")
        }
    }
    
    public static func load<T:Decodable>(forPath path: String) throws -> T {
        let loadedData = data(forPath: path)
        return try JSONDecoder().decode(T.self, from: loadedData)
    }
    
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
    
    
    
}
 
