//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error {
    
    var title: String { get }
    var description: String { get }
    
}

public enum GenericError: ErrorType {
    
    case network(Error?)
    case networkLoad(code: Int?)
    case networkDataError(details: String)
    case generalError(Error?)
    case sessionExpired
    case invalidLogin
    case appUpgradeRequired
    case networkNoContent
    
    public var title: String {
        switch self {
        case .network:
            return "network"
        case .networkLoad:
            return "networkLoad"
        case .networkDataError:
            return "networkDataError"
        case .generalError:
            return "generalError"
        case .sessionExpired:
            return "sessionExpired"
        case .invalidLogin:
            return "invalidLogin"
        case .appUpgradeRequired:
            return "appUpgradeRequired"
        case .networkNoContent:
            return "networkNoContent"
        }
    }
    
    public var description: String {
        switch self {
        case .network(let error):
            let errorString = error?.localizedDescription
            return "Error.Network".localized(with: errorString ?? "")
        case .networkLoad(let statusCode):
            return "Error.Network.Load".localized(with: statusCode ?? 0)
        case .generalError:
            return "Error.General".localized
        case .sessionExpired:
            return "Error.SessionExpired".localized
        case .invalidLogin:
            return "Login.Error.Message".localized
        case .appUpgradeRequired:
            return "Error.AppUpgradeRequired.Description".localized
        case .networkDataError(let details):
            return "Error.Network.Data".localized(with: details)
        case .networkNoContent:
            return "networkNoContent"
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
