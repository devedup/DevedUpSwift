//
//  File.swift
//  
//
//  Created by David Casserly on 12/11/2020.
//

import Foundation
import StoreKit

public protocol AppReviewService {
    func presentReviewPromptIfNeccessary()
    func requestReviewManually()
}

public final class DefaultAppReviewService: AppReviewService {

    private static let lastPromptKey = "lastVersionPromptedForReviewKey"
    
    public static let sharedInstance = DefaultAppReviewService()
    
    private init () {}
    
    public func presentReviewPromptIfNeccessary() {
        // Get the current bundle version for the app
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: DefaultAppReviewService.lastPromptKey)

        // Has the process been completed several times and the user has not already been prompted for this version?
        if currentVersion != lastVersionPromptedForReview {
            let twoSecondsFromNow = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion, forKey: DefaultAppReviewService.lastPromptKey)
            }
        }
    }
    
    public func requestReviewManually() {
        // Note: Replace the XXXXXXXXXX below with the App Store ID for your app
        //       You can find the App Store ID in your app's product URL
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/idXXXXXXXXXX?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
