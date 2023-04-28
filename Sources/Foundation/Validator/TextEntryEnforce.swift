//
//  File.swift
//  
//
//  Created by David Casserly on 05/08/2020.
//

import Foundation
import UIKit

public class TextEntryEnforce {
    
    public static func enforcePhoneNumberNoLeadingZero(text: String, textField: UITextField) -> Bool {
        if text == "0" {
            return false
        }
        if text.hasPrefix("0") {
            textField.text = String(text.dropFirst())
            return true
        }
        if text.count > 15 {
            return false
        }
        return false
    }
    
    public static func enforceNoCountryCode(countryCode: String, text: String, textField: UITextField) -> Bool {
        if text.hasPrefix(countryCode) {
            let newText = text.replacingOccurrences(of: countryCode, with: "")
            textField.text = newText
            return true
        } else {
            return false
        }
    }
    
    public static func enforceCountryCodeLeadingPlus(text: String, textField: UITextField) -> Bool {
        if !text.hasPrefix("+"){
            textField.text = "+\(text)"
            return false
        }
        if text.count > 4 {
            return false
        }
        return true
    }
    
}
