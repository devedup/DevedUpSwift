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

public struct OptionMessage {
    let title: String
    let confirmTitle: String
    let cancelTitle: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void
    
    public init(title: String, confirmTitle: String, cancelTitle: String, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        self.title = title
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
    
}

/// Presenter views which want to display errors should implement this protocol
public protocol MessagePresentable {
    func presentAppUpgrade(appID: String)
    func present(title: String, message: String, onDismiss: (() -> Void)?)
    
    func presentAlertOption(message: String, confirmTitle: String, cancelTitle: String, tintColour: UIColor?, onOK: (() -> Void)?, onCancel: (() -> Void)?)
    func presentActionSheetOption(message: String, confirmTitle: String, cancelTitle: String, tintColour: UIColor?, onOK: (() -> Void)?, onCancel: (() -> Void)?)
    
    func presentOption(optionMessage: OptionMessage)
    func presentOptionDestructive(message: String, confirmTitle: String, onOK: @escaping (() -> Void))
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
        
    public func presentAlertOption(message: String, confirmTitle: String, cancelTitle: String, tintColour: UIColor?, onOK: (() -> Void)?, onCancel: (() -> Void)?) {
        presentOption(message: message, confirmTitle: confirmTitle, cancelTitle: cancelTitle, tintColour: tintColour, style: .alert, onOK: onOK, onCancel: onCancel)
    }
    
    public func presentActionSheetOption(message: String, confirmTitle: String, cancelTitle: String, tintColour: UIColor?, onOK: (() -> Void)?, onCancel: (() -> Void)?) {
        presentOption(message: message, confirmTitle: confirmTitle, cancelTitle: cancelTitle, tintColour: tintColour, style: .actionSheet, onOK: onOK, onCancel: onCancel)
    }
    
    private func presentOption(message: String,
                       confirmTitle: String,
                       cancelTitle: String,
                       tintColour: UIColor?,
                       style: UIAlertController.Style = .alert,
                       onOK: (() -> Void)? = nil,
                       onCancel: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: style)
        
        // This is .cancel on purpose, because it's mor prominent
        let OKAction = UIAlertAction(title: confirmTitle, style: .default) { (action) in
            onOK?()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            onCancel?()
        }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = tintColour
    }
    
    public func presentOption(optionMessage: OptionMessage) {
        presentOption(message: optionMessage.title, confirmTitle: optionMessage.confirmTitle, cancelTitle: optionMessage.cancelTitle, tintColour: nil, onOK: optionMessage.confirmAction, onCancel: optionMessage.cancelAction)
    }
    
    public func presentOptionDestructive(message: String, confirmTitle: String, onOK: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: confirmTitle, style: .destructive) { (action) in
            onOK()
        }
        let cancelAction = UIAlertAction(title: "General.Button.Cancel".localized, style: .cancel) { (action) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
