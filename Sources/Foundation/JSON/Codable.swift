//  Created by David Casserly on 18/10/2019.
//

import Foundation

// This is a really naive implementation, as it's not generic.. but will do for now until I need to add more
extension KeyedDecodingContainer {

    public func decodeIfPresent(_ type: Double.Type, forKey key: K, transformFrom: String.Type) throws -> Double {
        let context = DecodingError.Context(codingPath: [key], debugDescription: "The key isn't there")
        guard let value = try decodeIfPresent(transformFrom, forKey: key) else {
            throw DecodingError.keyNotFound(key, context)
        }
        guard let doubleValue = Double(value) else {
            throw DecodingError.dataCorrupted(context)
        }
        return doubleValue
    }

    public func decode(_ type: Double.Type, forKey key: K, transformFrom: String.Type) throws -> Double {
        let context = DecodingError.Context(codingPath: [key], debugDescription: "The key isn't there")
        guard let doubleValue = Double(try decode(transformFrom, forKey: key)) else {
            throw DecodingError.dataCorrupted(context)
        }
        return doubleValue
    }

}
