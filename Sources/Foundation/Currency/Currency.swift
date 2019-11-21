//  Created by David Casserly on 02/11/2019.
//

import Foundation

extension Decimal {
    
    public var asCurrencyString: String {
        let currencyFormatter = Currency.formatter
        print(currencyFormatter)
        if let feeString = currencyFormatter.string(from: self as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
}


public class Currency {
    
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
    
    public static func formatted(amount: Decimal, locale: Locale = Locale(identifier: "en_GB")) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        if let feeString = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
}
