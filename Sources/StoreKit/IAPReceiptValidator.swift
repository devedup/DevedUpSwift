//
//  FlickrGalleryReceiptValidator.swift
//  galleryr
//
//  Created by David Casserly on 03/07/2020.
//

import Foundation

// THIS IS FLICKR GALLERY SPECIFIC AT THE MOMENT, NEED TO GENERALISE

@objc
final class IAPReceiptValidator: NSObject {
    
    @objc
    static let sharedInstance = IAPReceiptValidator()
    
    private let inAppPurchaseService = IAPService.sharedInstance
    
    private var originalProPackageIsActivated: Bool = {
        return DUKeychain.sharedKeyChain()?.bool(forKey: FGIAPProductStandardProPackage) ?? false
    }()
    
    @objc
    func validateReceipt(shouldRetryLoadRemoteReceipt: Bool = true) {
        let validationResult = inAppPurchaseService.validateReceipt()
        switch validationResult {
        case .success(let parsedReceipt):
            // This is where we enable app features, or disable them based on the subscription
            if let receipts = parsedReceipt.inAppPurchaseReceipts {
                // They have some receipts
                let proPackageReceipt = receipts.filter { $0.productIdentifier ?? "" == FGIAPProductStandardProPackage}
                if proPackageReceipt.count == 1 {
                    // They have the original PRO package - ensure enabled
                    FGIAPController.shared().proUP()
                } else {
                    // Check for the new subscriptions
                    processSubscriptionReceipts(receipts: receipts)
                }
            } else {
                // No pro features
            }
        case .error(let error):
            //couldNotFindReceipt would be called if they deleted app and re-installed
            // Should remove pro features
            Analytics.log(AnalyticsEventSwift.inAppPurchaseReceiptError(error: error))
            switch error {
            case .couldNotFindReceipt:
                // We can't find a receipt but they have the pro package flag, so lets download the receipt again
                if shouldRetryLoadRemoteReceipt && originalProPackageIsActivated {
                    inAppPurchaseService.requestReceiptRemotely {
                        // Recurse into this method again, but ensure not to loop by passing false
                        self.validateReceipt(shouldRetryLoadRemoteReceipt: false)
                    }
                } else {
                    // So we tried to download the receipt again and there still was no receipt. Not sure why they have the pro package
                    if originalProPackageIsActivated {
                        // Why do they have the pro package but no receipt ???
                        Analytics.log(.inAppPurchaseNoReceiptButHasPROPackage)
                    }
                }
            default:
                break
            }
        }
    }
    
    private func processSubscriptionReceipts(receipts: [ParsedInAppPurchaseReceipt]) {
        
    }
    
}
