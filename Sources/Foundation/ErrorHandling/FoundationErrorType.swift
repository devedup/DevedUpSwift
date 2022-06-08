//  Created by David Casserly on 27/02/2018.
import Foundation
import DevedUpSwiftLocalisation

public protocol FoundationErrorType: ErrorType {
}
public extension FoundationErrorType {
    // A default value for title here
    var title: String {
        let className = String(describing: Self.self)
        let value = NSLocalizedString(className, tableName: nil, bundle: Bundle.main, value: className, comment: "")
        return value
    }
}

public protocol NetworkDataProcessable {
    mutating func processDataForContext(processor: (Data) -> String)
}

/*
 
    The reason for all the substructs in here is because they surface in Firebase nicely when
    they have their own class/struct name
 
 */
public struct FoundationError  {
    
    public struct ContactsAuthDenied: FoundationErrorType {
        public init() {}
        public var description: String {
            return "You have denied permission for the data request"
        }
    }
    
    public struct ContactsError: FoundationErrorType {
        public init(_ error: Error?) {
            self.error = error
        }
        
        let error: Error?
        public var description: String {
            let errorString = underlyingError?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct HealthKitAuthDenied: FoundationErrorType {
        public init() {}
        public var description: String {
            return "You have denied permission for the data request"
        }
    }
    
    public struct HealthKitError: FoundationErrorType {
        public init(_ error: Error?) {
            self.error = error
        }
        
        let error: Error?
        public var description: String {
            let errorString = underlyingError?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct NoTokenAvailable: FoundationErrorType {
        public init() {}
        public var description: String {
            return ""
        }
    }
    
    public struct NetworkData: FoundationErrorType, NetworkDataProcessable {
        public init(statusCode: Int, data: Data?, context: String? = nil) {
            self.statusCode = statusCode
            self.context = context
            self.data = data
        }
        
        public let statusCode: Int
        public var context: String?
        public let data: Data?
        
        public var description: String {
            let details = context == nil ? "" : "[\(context ?? "")]"
            return "Error.Network.Details".localized(with: "\(statusCode)", "\(details)")
        }
        
        mutating public func processDataForContext(processor: (Data) -> String) {
            guard let data = self.data else {
                return
            }
            context = processor(data)
        }
    }
    
    public struct NetworkValidation: FoundationErrorType, NetworkDataProcessable {
        public init(statusCode: Int, data: Data?, context: String? = nil) {
            self.statusCode = statusCode
            self.context = context
            self.data = data
        }
        
        public let statusCode: Int
        public var context: String?
        public let data: Data?
        
        public var description: String {
            let details = context == nil ? "" : "\(context ?? "")"
            return "NetworkValidation.Details".localized(with: "\(details)", "\(statusCode)")
        }
        
        mutating public func processDataForContext(processor: (Data) -> String) {
            guard let data = self.data else {
                return
            }
            context = processor(data)
        }
    }
    
    public struct GeneralErrorString: FoundationErrorType {
        public init(_ string: String) {
            self.string = string
        }
        
        let string: String
        
        public var description: String {
            return "Error.General".localized + " \(string)"
        }
    }
    
    public struct SessionExpired: FoundationErrorType {
        public init(_ context: String?) {
            self.context = context
        }
        
        let context: String?
        
        public var description: String {
            return "Error.SessionExpired".localized + "\n\n \(context ?? "")"
        }
        
        public var shouldDisplayToUser: Bool { false }
    }
    
    public struct InvalidLogin: FoundationErrorType {
        public init(_ context: String?) {
            self.context = context
        }
        
        let context: String?
        
        public var description: String {
            return "Login.Error.Message".localized + "\n\n \(context ?? "")"
        }
    }
     
    public struct JSONParsingError: FoundationErrorType {
        public init(parseError: String, error: Error?) {
            self.parseError = parseError
            self.error = error
        }
        
        let parseError: String
        let error: Error?
        
        public var description: String {
            return "JSONParsingError.Details".localized(with: parseError)
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct NoInternetConnection: FoundationErrorType {
        public init() {}
        public var description: String {
            "Please check your network settings. You don't appear to have an active internet connection"
        }
        
    }
    
    public struct AppUpgradeRequired: FoundationErrorType {
        public init() {}
        public var description: String {
            return "Error.AppUpgradeRequired.Description".localized
        }
    }
    
    public struct CannotMakePurchases: FoundationErrorType {
        public init() {}
        public var description: String {
            return "It looks like you don't have permissions to make purchases on this device"
        }
    }
    
    public struct UserCancelled: FoundationErrorType {
        public init() {}
        public var description: String {
            return ""
        }
    }
    
    public struct InAppPurchaseWasCancelled: FoundationErrorType {
        public init() {}
        public var description: String {
            return ""
        }
    }
    
    public struct InAppPurchaseError: FoundationErrorType {
        public init(_ error: Error?) {
            self.error = error
        }
        
        let error: Error?
        public var description: String {
            let errorString = underlyingError?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct AppleSignInError: FoundationErrorType {
        public init(_ error: Error?) {
            self.error = error
        }
                
        let error: Error?
        
        public var description: String {
            let errorString = underlyingError?.localizedDescription
            return "Sign In Error: \(errorString ?? "")"
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct Network: FoundationErrorType {
        public init(error: Error?) {
            self.error = error
        }
        
        let error: Error?
        public var description: String {
            var errorString = "Error.Network".localized
            if let error = underlyingError as? ErrorType {
                errorString = error.description
            } else if let error = underlyingError as NSError? {
                errorString = error.localizedDescription
            }
            var extraDetail = ""
            if Debug.isDebugging() {
                var errorString = ""
                if let error = underlyingError as NSError? {
                    if let failedURLString = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String,
                        let failingURL = URL(string: failedURLString) {
                        errorString.append("\n\n Failing URL: \(failingURL.host ?? "")\(failingURL.path)")
                    }
                    errorString.append("\n\n \(error.domain) \(error.code)")
                    errorString.append("\n\n \(error.debugDescription)");
                }
                extraDetail = errorString
            }
            return errorString + extraDetail
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct GeneralError: FoundationErrorType {
        public init(_ error: Error?) {
            self.error = error
        }
        
        let error: Error?
        public var description: String {
            let errorString = underlyingError?.localizedDescription
            return "Error.General".localized + " \(errorString ?? "")"
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct SocketError: FoundationErrorType {
        public init(details: String?, error: Error?) {
            self.details = details
            self.error = error
        }
        
        let details: String?
        let error: Error?
        
        public var description: String {
            return "Socket.Error".localized(with: details ?? "")
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct SocketEndedError: FoundationErrorType {
        public init(details: String?, error: Error?) {
            self.details = details
            self.error = error
        }
        
        let details: String?
        let error: Error?
        
        public var description: String {
            return "Socket.Error".localized(with: details ?? "")
        }
        
        public var underlyingError: Error? { error ?? self }
    }
    
    public struct SocketNotConnectedError: FoundationErrorType {
        public init(details: String?) {
            self.details = details
        }
        
        let details: String?
        
        public var description: String {
            return "Socket.Error".localized(with: details ?? "")
        }
    }
    
}
