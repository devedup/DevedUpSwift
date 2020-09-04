//
//  InAppPurchaseService.swift
//  GalleryrPro
//
//  Created by David Casserly on 30/06/2020.
//

import Foundation
import StoreKit
import DevedUpSwiftFoundation

public protocol IAPService {
    
    /// Call this first to load your products
    /// - Parameters:
    ///   - identifiers: the identifiers that you want to load, you might have more on the app store that you're not interested in
    ///   - completion: The array of SKProduct
    func loadProducts(identifiers: [String], completion: @escaping ([SKProduct]) -> Void)
}

/**
 
    USAGE:
 
    1. Call  loadProducts(identifiers: [String], completion: @escaping ([SKProduct]) -> Void) to get a list of products
 
 */
public final class DefaultIAPService: NSObject, IAPService {
    
    static let sharedInstance = DefaultIAPService()

//    private let receiptValidator = ReceiptValidator()
    
    // Load Products
    private var loadProductsRequest = SKProductsRequest()
    private var loadProductsCompletion: ( ([SKProduct]) -> Void )?
    
    // Receipt requests - if the receipt is not on the device
    private let receiptRequest = SKReceiptRefreshRequest()
    private var receiptRequestCompletion: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    // MARK: Start and Stop Monitor
    
    // Start and Stop Observing payment queue
    // didFinishLaunchingWithOptions
    func beginPaymentQueueMonitor() {
        SKPaymentQueue.default().add(self)
    }
    
    // applicationWillTerminate
    func stopPaymentQueueMonitor() {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: Products
    
    public func loadProducts(identifiers: [String], completion: @escaping ([SKProduct]) -> Void) {
        loadProductsCompletion = completion
        loadProductsRequest.cancel()
        loadProductsRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        loadProductsRequest.delegate = self        
        loadProductsRequest.start()
    }
    
    // MARK: Receipts
    
//    func validateReceipt() -> ReceiptValidationResult {
//        return receiptValidator.validateReceipt()
//        switch validationResult {
//        case .success(let parsedReceipt):
//            // Enable app features
//            print("Valid receipt \(parsedReceipt)")
//        case .error(let error):
//            
//            
//        }
//    }
    
    func requestReceiptRemotely(completion: @escaping () -> Void) {
        self.receiptRequestCompletion = completion
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: receiptUrl.absoluteString) {
                receiptRequest.delegate = self
                receiptRequest.start()
            } else {
                print("The file was already there")
            }
        }
    }
    
    
//    - (void) retrieveEligibleProductsCompletion:( void (^)(NSArray *productList, NSError *error))completion {
//        self.productCompletion = completion;
//        [self.productRequest cancel];
//        self.productRequest.delegate = nil;
//        self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[FGIAPProductStandardProPackage]]];
//        self.productRequest.delegate = self;
//        [self.productRequest start];
//    }
    
    
}

extension DefaultIAPService: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.loadProductsCompletion?(response.products)
        }
    }
    
}

extension DefaultIAPService: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        print("The request finished successfully")
        self.receiptRequestCompletion?()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
        self.receiptRequestCompletion?()
    }
    
}


extension DefaultIAPService: SKPaymentTransactionObserver {
    
    // Observe transaction updates.
    public func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
        
    }
    
}
