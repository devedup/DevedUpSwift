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
    func loadProducts(identifiers: [String], completion: @escaping AsyncResultCompletion<[IAPProduct]>)
    
    /// Initiate the purchase of a product
    ///
    /// - Parameters:
    ///   - product: The product
    ///   - completion: SKPaymentTransactionif it worked
    func purchase(product: SKProduct, completion: @escaping AsyncResultCompletion<SKPaymentTransaction>)
    
    /// Restore your transactions
    ///
    /// - Parameter completion: SKPaymentTransactionif it worked
    func restore(completion: @escaping AsyncResultCompletion<[SKPaymentTransaction]>)
}

/**
 
    USAGE:
 
    1. Call  loadProducts(identifiers: [String], completion: @escaping ([SKProduct]) -> Void) to get a list of products
 
 */
public final class DefaultIAPService: NSObject, IAPService {
    
    public static let sharedInstance = DefaultIAPService()

//    private let receiptValidator = ReceiptValidator()
    
    // Load Products
    private var loadProductsRequest = SKProductsRequest()
    private var loadProductsCompletion: AsyncResultCompletion<[IAPProduct]>?
    
    // Purchase
    private var puchaseCompletion: AsyncResultCompletion<SKPaymentTransaction>?
    private var restoreCompletion: AsyncResultCompletion<[SKPaymentTransaction]>?
    
    // Receipt requests - if the receipt is not on the device
    private let receiptRequest = SKReceiptRefreshRequest()
    private var receiptRequestCompletion: (() -> Void)?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
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
    
    public func loadProducts(identifiers: [String], completion: @escaping AsyncResultCompletion<[IAPProduct]>) {
        loadProductsCompletion = completion
        loadProductsRequest.cancel()
        loadProductsRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        loadProductsRequest.delegate = self        
        loadProductsRequest.start()
    }
    
    // MARK: Purchase
    
    public func purchase(product: SKProduct, completion: @escaping AsyncResultCompletion<SKPaymentTransaction>) {
        self.puchaseCompletion = completion
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(GenericError.cannotMakePurchases))
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: Restore
    
    public func restore(completion: @escaping AsyncResultCompletion<[SKPaymentTransaction]>) {
        self.restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
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

extension DefaultIAPService: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var restoredTransactions: [SKPaymentTransaction]?
        transactions.forEach {
            switch $0.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction($0)
                self.puchaseCompletion?(.success($0))
            case .restored:
                SKPaymentQueue.default().finishTransaction($0)
                if restoredTransactions == nil {
                    restoredTransactions = [SKPaymentTransaction]()
                }
                restoredTransactions?.append($0)
            case .failed:
                var paymentWasCancelled = false
                if let error = $0.error as NSError? {
                    if error.code == SKError.paymentCancelled.rawValue {
                        paymentWasCancelled = true
                    }
                }
                SKPaymentQueue.default().finishTransaction($0)
                if (paymentWasCancelled) {
                    self.puchaseCompletion?(.failure(GenericError.inAppPurchaseWasCancelled))
                } else {
                    self.puchaseCompletion?(.failure(GenericError.inAppPurchaseError($0.error)))
                }
            case .deferred, .purchasing:
                break
            @unknown default:
                self.puchaseCompletion?(.failure(GenericError.generalErrorString("Unknown case in in app purchase payment")))
            }
        }
        // If we did a restore... then we'd call this instead
        // When i restore, I get every transaction returned !!
        if let restored = restoredTransactions {
            self.restoreCompletion?(.success(restored))
            self.restoreCompletion = nil
        }
    }
    
    //restoreCompletedTransactionsFailedWithError
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        var restoreWasCancelled = false
        if let error = error as NSError? {
            if error.code == SKError.paymentCancelled.rawValue {
                restoreWasCancelled = true
            }
        }
        if (restoreWasCancelled) {
            self.puchaseCompletion?(.failure(GenericError.inAppPurchaseWasCancelled))
        } else {
            self.puchaseCompletion?(.failure(GenericError.inAppPurchaseError(error)))
        }
    }
    
    
    /*
     
     - (void)    completeSuccessfulTransaction:(SKPaymentTransaction *)transaction {
         if ([transaction.payment.productIdentifier isEqualToString:FGIAPProductStandardProPackage]) {
             // They have successfully purchase the pro package
             // DELIVER THE FEATURE !!!
             [self proUP];
             [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
             if (self.purchaseCompletion) {
                 self.purchaseCompletion(nil);
             }
         }
     }

     - (void) completeFailedTransaction:(SKPaymentTransaction *)transaction {
         [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
         if (self.purchaseCompletion) {
             NSString *errorCode = [NSString stringWithFormat:@"%li", (long)(transaction.error).code];
             [[Tracking sharedController] logEvent:@"InAppPurchase" withKey:@"TransactionError" value:errorCode];
             self.purchaseCompletion(transaction.error);
         }
     }

     #pragma mark - SKPaymentTransactionObserver

     - (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
         for (SKPaymentTransaction *transaction in transactions) {
             switch (transaction.transactionState) {
                 case SKPaymentTransactionStatePurchased:
                     [Analytics log:AnalyticsEventPurchasedProPackage params:nil];
                     [[Tracking sharedController] logEvent:@"InAppPurchase" withKey:@"Transaction" value:@"Purchased"];
                     [self completeSuccessfulTransaction:transaction];
                     break;
                 case SKPaymentTransactionStateFailed:
                     [[Tracking sharedController] logEvent:@"InAppPurchase" withKey:@"Transaction" value:@"Failed"];
                     [self completeFailedTransaction:transaction];
                     break;
                 case SKPaymentTransactionStateRestored:
                     [[Tracking sharedController] logEvent:@"InAppPurchase" withKey:@"Transaction" value:@"Restored"];
                     [self completeSuccessfulTransaction:transaction];
                 case SKPaymentTransactionStateDeferred:
                 case SKPaymentTransactionStatePurchasing:
                     break;
             }
         }
     }
     
     */
}

extension DefaultIAPService: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            let products = response.products.map { IAPProduct(skProduct: $0) }
            self.loadProductsCompletion?(.success(products))
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
