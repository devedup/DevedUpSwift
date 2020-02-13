//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error, CustomStringConvertible {
    
    var title: String { get }
    var description: String { get }
    
}

public enum GenericError: ErrorType {
    
    case network(Error?)
    case networkLoad(code: Int?)
    case generalError(Error?)
    
    public var title: String {
        switch self {
        default:
            return ""
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
