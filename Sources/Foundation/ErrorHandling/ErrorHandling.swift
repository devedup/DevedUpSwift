//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error {
    
    var title: String { get }
    var description: String { get }
    
}

public enum GenericError: ErrorType {
    
    case networkData(statusCode: Int, data: Data?)
    case network(error: Error?)
    case generalError(Error?)
    case sessionExpired
    case invalidLogin
    case appUpgradeRequired

    
    public var title: String {
        switch self {
        case .network, .networkData:
            return "networkErrorTitle".localized
        case .generalError:
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
        case .network(let error):
            let errorString = error?.localizedDescription
            return "Error.Network".localized + ": \(errorString ?? "")"
        case .networkData(let statusCode, let data):
            return "The request responded with a status of \(statusCode)"
        case .generalError(let error):
            let errorString = error?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
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
