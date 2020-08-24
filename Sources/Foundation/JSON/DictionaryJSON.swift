//
//  File.swift
//  
//
//  Created by David Casserly on 20/08/2020.
//

import Foundation

extension Dictionary {
    
    public func toModel<T: Decodable>() -> T? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: theJSONData)
    }

}
