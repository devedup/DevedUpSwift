//
//  File.swift
//  
//
//  Created by David Casserly on 26/05/2021.
//

import Foundation
import DevedUpSwiftFoundation
import MessageUI

public enum EmailResult {
    case cancelled
    case success
}

public protocol EmailController {
    func canSendMail() -> Bool
    func presentMailComposer(over viewController: UIViewController, subject: String, body: String, to: String, isHTML: Bool, completion: @escaping AsyncResultCompletion<EmailResult>)
}

public class DefaultEmailController: NSObject, EmailController {
    
    private var completionBlock: AsyncResultCompletion<EmailResult>?

    public static let sharedInstance = DefaultEmailController()
    
    private override init() {}
    
    public func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    public func presentMailComposer(over viewController: UIViewController, subject: String, body: String, to: String, isHTML: Bool, completion: @escaping AsyncResultCompletion<EmailResult>) {
        guard canSendMail() else {
            return
        }
        
        self.completionBlock = completion
        
        let emailController = MFMailComposeViewController()
        emailController.setToRecipients([to])
        emailController.setSubject(subject)
        emailController.setMessageBody(body, isHTML: isHTML)
        emailController.mailComposeDelegate = self
        
        viewController.present(emailController, animated: true, completion: nil)
    }
}

extension DefaultEmailController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .cancelled {
            self.completionBlock?(.success(EmailResult.cancelled))
        } else if error != nil || result == .failed {
            self.completionBlock?(.failure(FoundationError.GeneralError(error)))
        } else {
            self.completionBlock?(.success(EmailResult.success))
        }
    }
}
