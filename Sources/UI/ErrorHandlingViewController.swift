//  UIViewController+ErrorPresentable.swift
//
//  Created by David Casserly on 13/05/2018.
import Foundation
import UIKit
import DevedUpSwiftFoundation

extension Notification {
    public func userInfoValue(forKey key: String) -> String? {
        return userInfo?[key] as? String
    } 
}

extension Notification.Name {
    public static let presentAlert = Notification.Name("presentAlert")
}

extension String {
    public struct Constant {
        public static let alertErrorObjectKey = "alertErrorObjectKey"
        public static let alertTitleKey = "AlertTitleKey"
        public static let alertMessageKey = "AlertMessageKey"
    }
}

extension NotificationCenter {
    
    public static func presentAlert(message: String, title: String, error: ErrorType) {
        let userInfo = [String.Constant.alertMessageKey: message, String.Constant.alertTitleKey: title, String.Constant.alertErrorObjectKey: error as ErrorType] as [String : Any]
        NotificationCenter.default.post(name: .presentAlert, object: nil, userInfo: userInfo)
    }
    
    public static func present(error: ErrorType) {
        presentAlert(message: error.description, title: error.title, error: error)
    }
    
}

/// Presenter views which want to display errors should implement this protocol
public protocol ErrorPresentable {
    func present(_ error: Error)
    func present(_ error: ErrorType)
    func presentErrorAsAlert(_ error: ErrorType, onDismiss: (() -> Void)?)
    func presentErrorAfterPop(_ error: ErrorType)
    func presentAlertMessage(title: String, message: String, onDismiss: (() -> Void)?)
}

// MARK: - Lets make all ViewControllers be ErrorPresentable
extension UIViewController: ErrorPresentable {

    public func present(_ error: Error) {
        if let errorType = error as? ErrorType {
            present(errorType)
        } else {
            present(FoundationError.GeneralError(error))
        }
    }
    
    /// - Parameter error: the error you are presenting
    public func present(_ error: ErrorType) {
        NotificationCenter.present(error: error)
    }

    public func presentErrorAsAlert(_ error: ErrorType, onDismiss: (() -> Void)? = nil) {
        let title = error.title
        let message = error.description
        presentAlertMessage(title: title, message: message, onDismiss: onDismiss)
    }
    
    public func presentAlertMessage(title: String, message: String, onDismiss: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "General.Button.Ok".localized, style: .default) { (action) in
            onDismiss?()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    public func presentErrorAfterPop(_ error: ErrorType) {
        navigationController?.dismiss(animated: true, completion: {
            self.present(error)
        })
    }
    
    
    
}
