//  Created by David Casserly on 02/11/2019.
//

import Foundation

public class Currency {
    
    public static func calculateFee(amount: Int, percent: Double) -> Decimal {
        let decimalAmount = Decimal(integerLiteral: amount)
        let decimalFee = Decimal(percent) / Decimal(integerLiteral: 100)
        let fee = decimalAmount * decimalFee
        return fee
    }
    
    public static func formatted(amount: Decimal, locale: Locale = Locale(identifier: "en_GB")) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        if let feeString = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return feeString
        } else {
            return "error"
        }
    }
    
}
