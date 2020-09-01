//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error {
    
    var title: String { get }
    var description: String { get }
    var detail: String { get }
    
}

public enum GenericError: ErrorType {
    
    case networkData(statusCode: Int, data: Data?)
    case network(error: Error?)
    case generalError(Error?)
    case generalErrorString(String)
    case sessionExpired
    case invalidLogin
    case appUpgradeRequired

    
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
        }
    }
    
    public var description: String {
        switch self {
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
        case .networkData(let statusCode, _):
            return "The request responded with a status of \(statusCode)"
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
        case .networkData(let statusCode, _):
            return "The request responded with a status of \(statusCode)"
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
