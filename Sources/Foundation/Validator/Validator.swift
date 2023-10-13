//  Validator.swift
//
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//

import Foundation

public protocol Validatable {
    func validate() -> ValidationError?
}

public struct ValidationError: ErrorType {
    
    public var underlyingError: Error {
        return self
    }
    
    public let title: String = ""
    public let description: String
    public let detail: String = ""
    
    public init(errorMessages: String) {
        self.description = errorMessages
    }
}

public class Validator {
    
    private init() {
    }
    
    public static func validateCreditCard(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
    public static func validateEmail(_ text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    public static func validateFullPhoneNumber(_ text: String) -> Bool  {
        do {
            let regex = try NSRegularExpression(pattern: "^\\+(?:[0-9] ?){6,14}[0-9]$", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    public static func validatePhoneNumberNoCode(_ text: String) -> Bool  {
        do {
            let regex = try NSRegularExpression(pattern: "^[0][0-9]{6,14}$", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    public static func validatePhoneNumberNoCodeNoLeadingZero(_ text: String) -> Bool  {
        do {
            let regex = try NSRegularExpression(pattern: "^[1-9][0-9]{5,14}$", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    public static func validatePhoneCode(_ text: String) -> Bool  {
        do {
            let regex = try NSRegularExpression(pattern: "^[\\+][1-9][0-9]{0,2}$", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    public static func validatePositiveAmount(_ text: String) -> Bool {
        guard let floatValue = Float(text),
            floatValue > 0 else {
                return false
        }
        return true
    }
    
    public static func validateAndConfirmMail(email: String, otherEmail: String) -> Bool {
        return (email == otherEmail) && validateEmail(otherEmail)
    }
    
    public static func validateTextLength(_ text: String, range: ClosedRange<Int>) -> Bool {
        return range.contains(text.count)
    }
    
    public static func validateHasLength(_ text: String) -> Bool {
        return text.count > 0
    }

    public static func validateMinimumLength(_ text: String, min: Int) -> Bool {
        return text.count >= min
    }
    
    public static func validateMinimumMaximumLength(_ text: String, min: Int, max: Int) -> Bool {
        return text.count >= min && text.count <= max
    }
    
    public static func validateSingleNumber(_ text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9]$", options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regex.matches(in: text, options: [], range: range)
            return matches.count > 0
        }
        catch let error {
            print(error)
            return false
        }
    }
    
}
