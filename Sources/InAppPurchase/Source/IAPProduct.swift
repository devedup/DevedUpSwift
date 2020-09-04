//
//  InAppPurchaseProduct.swift
//  GalleryrPro
//
//  Created by David Casserly on 30/06/2020.
//

import Foundation
import StoreKit

final class IAPProduct {
    
    let product: SKProduct
    let purchased: Bool
    let productDescription: String
    
    init(product: SKProduct, purchased: Bool, productDescription: String) {
        self.product = product
        self.purchased = purchased
        self.productDescription = productDescription
    }
    
}
