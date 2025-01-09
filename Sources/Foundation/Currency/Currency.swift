//  Created by David Casserly on 02/11/2019.
//

import Foundation

public struct PoundsAndPence: Equatable, Hashable {
    public init(pounds: String, pence: String) {
        self.pounds = pounds
        self.pence = pence
    }
    
    public let pounds: String
    public let pence: String
}

extension Decimal {
    
    public var asCurrencyPoundsAndPence: PoundsAndPence {
        let pounds = Currency.poundFormatter.string(from: self as NSDecimalNumber) ?? ""
        let pence = Currency.penceFormatter.string(from: self as NSDecimalNumber) ?? ""
        return PoundsAndPence(pounds: pounds, pence: pence)
    }
    
    public var asCurrencyString: String {
        let currencyFormatter = Currency.formatter
        if let feeString = currencyFormatter.string(from: self as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
    public var asCurrencyStringWithPound: String {
        let currencyFormatter = Currency.formatter
        currencyFormatter.numberStyle = .currency
        if let feeString = currencyFormatter.string(from: self as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
}


public class Currency {
    
    fileprivate static let penceFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = false
        currencyFormatter.maximumIntegerDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.locale = Locale(identifier: "en_GB") // obviously this isn't going to work long term with multiple currencies
        return currencyFormatter
    }()
    
    fileprivate static let poundFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = false
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.roundingMode = .down
        currencyFormatter.locale = Locale(identifier: "en_GB") // obviously this isn't going to work long term with multiple currencies
        return currencyFormatter
    }()
    
    fileprivate static let formatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        print("here")
        currencyFormatter.usesGroupingSeparator = false
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.locale = Locale(identifier: "en_GB") // obviously this isn't going to work long term with multiple currencies
        return currencyFormatter
    }()
    
    public static func calculateFee(amount: Int, percent: Decimal) -> Decimal {
        let decimalAmount = Decimal(integerLiteral: amount)
        let decimalFee = percent / Decimal(integerLiteral: 100)
        let fee = decimalAmount * decimalFee
        return fee
    }
    
    public static func formatted(amount: Decimal, locale: Locale = Locale(identifier: "en_GB"), numberStyle: NumberFormatter.Style = .currency) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.numberStyle = numberStyle
        currencyFormatter.locale = locale
        if let feeString = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
}
