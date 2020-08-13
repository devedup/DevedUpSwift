//  Created by David Casserly on 18/10/2019.
//

import Foundation
import UIKit

public enum ImageEncodingQuality: Float {
    case png = 0
    case jpegLow = 0.2
    case jpegMid = 0.5
    case jpegHigh = 0.75
}

// This is a really naive implementation, as it's not generic.. but will do for now until I need to add more
extension KeyedDecodingContainer {
    
    public func decodeIfPresent(_ type: Double.Type, forKey key: K) throws -> Double? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let doubleValue = Double(stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Double value")
            throw DecodingError.typeMismatch(type, context)
        }
        return doubleValue
    }
    
    public func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        let stringValue = try decode(String.self, forKey: key)
        guard let doubleValue = Double(stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Double value")
            throw DecodingError.typeMismatch(type, context)
        }
        return doubleValue
    }
    
    /// Decimal for monetary values
    public func decodeIfPresent(_ type: Decimal.Type, forKey key: K) throws -> Decimal? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Decimal value")
            throw DecodingError.typeMismatch(type, context)
        }
        return decimalValue
    }
    
    public func decode(_ type: Decimal.Type, forKey key: K) throws -> Decimal {
        let stringValue = try decode(String.self, forKey: key)
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Decimal value")
            throw DecodingError.typeMismatch(type, context)
        }
        return decimalValue
    }
    
    /// Dates with custom formatters
    public func decode(_ type: Date.Type, formatter: DateFormatter, forKey key: K) throws -> Date {
        let stringValue = try decode(String.self, forKey: key)
        if let date = formatter.date(from: stringValue) {
            return date
        } else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "Date string for key \(key )does not match format expected by formatter \(String(describing: formatter.dateFormat)).")
            throw DecodingError.typeMismatch(type, context)
        }
    }
    
    // Images
    public func decode(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) throws -> UIImage {
        let imageData = try decode(Data.self, forKey: key)
        if let image = UIImage(data: imageData) {
            return image
        } else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) could not be converted to a UIImage.")
            throw DecodingError.typeMismatch(type, context)
        }
    }
}

extension KeyedEncodingContainer {
    
    public mutating func encode(_ value: UIImage,
                         forKey key: KeyedEncodingContainer.Key,
                         quality: ImageEncodingQuality = .png) throws {
        var imageData: Data!
        if quality == .png {
            imageData = value.pngData()
        } else {
            imageData = value.jpegData(compressionQuality: CGFloat(quality.rawValue))
        }
        try encode(imageData, forKey: key)
    }
    
}
