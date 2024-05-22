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
    
    public var subscriptionPeriod: IAPProductSubscriptionPeriod? {
        guard let period = skProduct.subscriptionPeriod else {
            return nil
        }
        return IAPProductSubscriptionPeriod(skSubscriptionPeriod: period, price: skProduct.price, priceLocale: skProduct.priceLocale)
    }
    
    public var introductoryPeriod: IAPProductSubscriptionPeriod? {
        guard let introPrice = skProduct.introductoryPrice else {
            return nil
        }
        return IAPProductSubscriptionPeriod(skSubscriptionPeriod: introPrice.subscriptionPeriod, price: introPrice.price, priceLocale: introPrice.priceLocale)
    }
    
}

public struct IAPProductSubscriptionPeriod {
    let skSubscriptionPeriod: SKProductSubscriptionPeriod
    let price: NSDecimalNumber
    let priceLocale: Locale
    
    public var displayPrice: String {
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .currency
        numberFormat.formatterBehavior = .behavior10_4
        numberFormat.locale = priceLocale
        return numberFormat.string(from: price) ?? ""
    }
    
    public var months: Int {
        let unit = skSubscriptionPeriod.unit
        let number = skSubscriptionPeriod.numberOfUnits
        
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
        let price = price as Decimal
        let perMonth = price / Decimal(integerLiteral: months)
        return perMonth
    }
    
    public var displayPerMonth: String {
        let amount = Currency.formatted(amount: perMonth, locale: priceLocale)
        return "(\(amount) / month)"
    }
}
