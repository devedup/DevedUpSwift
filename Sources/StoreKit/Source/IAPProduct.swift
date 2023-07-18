//
//  InAppPurchaseProduct.swift
//  GalleryrPro
//
//  Created by David Casserly on 30/06/2020.
//

import Foundation
import StoreKit
import DevedUpSwiftFoundation

public struct IAPProduct {
    
    public let skProduct: SKProduct
    
    public var displayPrice: String {
        return skProduct.priceString
    }
    
    public var months: Int {
        guard let unit = skProduct.subscriptionPeriod?.unit,
            let number = skProduct.subscriptionPeriod?.numberOfUnits else {
            return 0
        }
        
        switch unit {
        case .month:
            return number
        case .year:
            return number * 12
        default:
            return 0
        }
    }
    
    public var displayPeriodNumeric: String {
        return "\(months)"
    }
    
    public var displayPeriodText: String {
        return "month" + (months > 1 ? "s" : "")
    }
    
    public var displayMonths: String {
        return "\(months) month" + (months > 1 ? "s" : "")
    }
    
    private var perMonth: Decimal {
        let price = skProduct.price as Decimal
        let perMonth = price / Decimal(integerLiteral: months)
        return perMonth
    }
    
    public var displayPerMonth: String {
        let amount = Currency.formatted(amount: perMonth, locale: skProduct.priceLocale)
        return "(\(amount) / month)"
    }
    
}

extension SKProduct {
        
    var priceString: String {
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .currency
        numberFormat.formatterBehavior = .behavior10_4
        numberFormat.locale = priceLocale
        return numberFormat.string(from: price) ?? ""
    }
    
}
