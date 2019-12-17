//  Created by David Casserly on 27/02/2018.
import Foundation

public protocol ErrorType: Error, CustomStringConvertible {
    
    var title: String { get }
    var description: String { get }
    
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
