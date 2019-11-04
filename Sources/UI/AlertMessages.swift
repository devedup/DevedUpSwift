//  UIViewController+MessagePresentable.swift
//

import Foundation
import UIKit
import DevedUpSwiftLocalisation

/**
 
 Localizations needed
 
 "General.Button.Cancel" = "Cancel";
 "General.Button.Ok" = "Ok";
 "Error.AppUpgradeRequired.Title" = "Update Required";
 "Error.AppUpgradeRequired.Description" = "We've made some improvements! Please download the latest version from the App Store.";
 
 */

/// Presenter views which want to display errors should implement this protocol
public protocol MessagePresentable {
    func presentAppUpgrade(appID: String)
    func present(title: String, message: String, onDismiss: (() -> Void)?)
    func presentOption(message: String, confirmTitle: String, cancelTitle: String, onOK: (() -> Void)?, onCancel: (() -> Void)?)
}

extension MessagePresentable {
    
    public func presentOption(message: String, onOK: (() -> Void)?, onCancel: (() -> Void)?) {
        presentOption(message: message, confirmTitle: "General.Button.Ok".localized, cancelTitle: "General.Button.Cancel".localized, onOK: onOK, onCancel: onCancel)
    }
    
}

// MARK: - Lets make all ViewControllers be ErrorPresentable
extension UIViewController: MessagePresentable {
    
    public func presentAppUpgrade(appID: String) {
        let title = "Error.AppUpgradeRequired.Title".localized
        let message = "Error.AppUpgradeRequired.Description".localized
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "General.Button.Ok".localized, style: .default) { (action) in
            let urlStr = "itms-apps://apps.apple.com/gb/app/city-wega/\(appID)"
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(OKAction)
        
        if let top = UIApplication.topViewController() {
            top.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Present a message from a UIAlertController, with an OK button to dimiss.
    ///
    /// - Parameter message: the message you are presenting
    public func present(title: String, message: String, onDismiss: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "General.Button.Ok".localized, style: .default) { (action) in
            onDismiss?()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
        
    public func presentOption(message: String,
                       confirmTitle: String,
                       cancelTitle: String,
                       onOK: (() -> Void)? = nil,
                       onCancel: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: confirmTitle, style: .default) { (action) in
            onOK?()
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default) { (action) in
            onCancel?()
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
