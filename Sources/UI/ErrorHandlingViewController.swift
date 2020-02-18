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
        public static let alertMessageKey = "AlertMessageKey"
    }
}

extension NotificationCenter {
    
    public static func presentAlert(message: String) {
        let userInfo = [String.Constant.alertMessageKey: message]
        NotificationCenter.default.post(name: .presentAlert, object: nil, userInfo: userInfo)
    }
    
    public static func present(error: ErrorType) {
        let errorMessage = error.description
        presentAlert(message: errorMessage)
    }
    
}

/// Presenter views which want to display errors should implement this protocol
public protocol ErrorPresentable {
    func present(_ error: ErrorType)
    func presentErrorAsAlert(_ error: ErrorType, onDismiss: (() -> Void)?)
    func presentErrorAfterPop(_ error: ErrorType)
}

// MARK: - Lets make all ViewControllers be ErrorPresentable
extension UIViewController: ErrorPresentable {

    /// - Parameter error: the error you are presenting
    public func present(_ error: ErrorType) {
        NotificationCenter.present(error: error)
    }

    public func presentErrorAsAlert(_ error: ErrorType, onDismiss: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)

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
