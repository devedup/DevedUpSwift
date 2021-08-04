//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error {
    
    var title: String { get }
    var description: String { get }
    var detail: String { get }
    var underlyingError: Error { get }
    
}

public enum GenericError: ErrorType {
    
    case networkData(statusCode: Int, context: String?, data: Data?)
    case noInternetConnection
    case network(error: Error?)
    case generalError(Error?)
    case generalErrorString(String)
    case sessionExpired(context: String?)
    case invalidLogin(context: String?)
    case appUpgradeRequired
    case cannotMakePurchases
    case inAppPurchaseError(Error?)
    case inAppPurchaseWasCancelled
    case appleSignInError(Error?)
    case userCancelled
    
    public var underlyingError: Error {
        switch self {
        case .network(let error), .generalError(let error), .inAppPurchaseError(let error), .appleSignInError(let error):
            if let underlyingError = error {
                return underlyingError
            } else {
                return self
            }
        default:
            return self
        }
    }
    public var title: String {
        switch self {
        case .network, .networkData:
            return "networkErrorTitle".localized
        case .generalError, .generalErrorString:
            return "generalError".localized
        case .sessionExpired:
            return "sessionExpired".localized
        case .invalidLogin:
            return "invalidLogin".localized
        case .appUpgradeRequired:
            return "appUpgradeRequired".localized
        case .cannotMakePurchases, .inAppPurchaseError:
            return "Purchase Error"
        case .inAppPurchaseWasCancelled:
            return "Purchase was cancelled"
        case .appleSignInError:
            return "Apple Sign In Error"
        case .userCancelled:
            return ""
        case .noInternetConnection:
            return "No Internet"
        }
    }
    
    public var description: String {
        switch self {
        case .noInternetConnection:
            return "Please check your network settings. You don't appear to have an active internet connection"
        case .network(let errorFound):
            var errorString = "Error.Network".localized
            if let error = errorFound as NSError? {
                errorString = error.localizedDescription
            }
            var extraDetail = ""
            if Debug.isDebugging() {
                extraDetail = detail
            }
            return errorString + extraDetail
        case .networkData(let statusCode, let context, _):
            let details = context == nil ? "" : "[\(context ?? "")]"
            return "Error.Network.Details".localized(with: "\(statusCode)", "\(details)")
        case .generalError(let error):
            let errorString = error?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        case .generalErrorString(let errorDetail):
            return "Error.General".localized + " \(errorDetail)"
        case .sessionExpired(let context):
            return "Error.SessionExpired".localized + "\n\n \(context ?? "")"
        case .invalidLogin(let context):
            return "Login.Error.Message".localized + "\n\n \(context ?? "")"
        case .appUpgradeRequired:
            return "Error.AppUpgradeRequired.Description".localized
        case .cannotMakePurchases:
            return "It looks like you don't have permissions to make purchases on this device"
        case .inAppPurchaseError(let error):
            let errorString = error?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        case .appleSignInError(let error):
            let errorString = error?.localizedDescription
            return "Sign In Error: \(errorString ?? "")"
        case .userCancelled, .inAppPurchaseWasCancelled:
            return ""
        }
    }
    
    public var detail: String {
        switch self {
        case .network(let errorFound):
            var errorString = ""
            if let error = errorFound as NSError? {
                if let failedURLString = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String,
                    let failingURL = URL(string: failedURLString) {
                    errorString.append("\n\n Failing URL: \(failingURL.host ?? "")\(failingURL.path)")
                }
                errorString.append("\n\n \(error.domain) \(error.code)")
                errorString.append("\n\n \(error.debugDescription)");
            }
            return errorString
        case .networkData(let statusCode, let context, _):
            let details = context == nil ? "" : "[\(context ?? "")]"
            return "The request responded with a status of [\(statusCode)] \(details)"
        case .generalError(let error):
            let errorString = error?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        case .generalErrorString(let errorDetail):
            return "Error.General".localized + " \(errorDetail)"
        case .sessionExpired:
            return "Error.SessionExpired".localized
        case .invalidLogin:
            return "Login.Error.Message".localized
        case .appUpgradeRequired:
            return "Error.AppUpgradeRequired.Description".localized
        default:
            return ""
        }
    }

}

// Below an example...:::
/*
enum AppError: ErrorType {
    
    // Network and General Error
    case errorString (String)
    case generalError (Error?)
    
    
    var title: String {
        switch self {
        default:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .errorString(let errorString):
            return errorString
        case .generalError:
            return localizedString("Error.General")
        }
    }
    
}
*/
