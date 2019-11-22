//  JSONLoader
//  Created by David Casserly on 01/02/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.

import Foundation

class JSONLoader {
    
    static func data(forPath path: String) -> Data {
        let testBundle = Bundle.main
        let path = testBundle.path(forResource: path, ofType: "json")
        let filePath = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: filePath)
        return data
    }
    
    static func load<T:Decodable>(forPath path: String) throws -> T {
        let loadedData = data(forPath: path)
        return try JSONDecoder().decode(T.self, from: loadedData)
    }
    
}
