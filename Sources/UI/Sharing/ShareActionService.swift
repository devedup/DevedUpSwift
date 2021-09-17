//
//  ShareActionService.swift
//  ManchesterFC
//
//  Created by David Casserly on 08/05/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public protocol Shareable {
    var subject: String { get }
    var message: String { get }
    var messageShort: String? { get }
    var url: URL { get }
}

public protocol ShareActionService {
    func share(shareable: Shareable, from viewController: UIViewController, completion: @escaping () -> Void)
    func share(message: MessageWithSubject, from viewController: UIViewController, completion: @escaping () -> Void)
}

final public class DefaultShareActionService: ShareActionService {
    
    public static let sharedInstance = DefaultShareActionService()
    
    private init() {}
    
    public func share(shareable: Shareable, from viewController: UIViewController, completion: @escaping () -> Void) {
        share(message: MessageWithSubject(shareable: shareable), from: viewController, completion: completion)
    }
    
    public func share(message: MessageWithSubject, from viewController: UIViewController, completion: @escaping () -> Void) {
        let activityViewController =
            UIActivityViewController(activityItems: [message],
                                     applicationActivities: nil)
        
        // iPad support
        if let view = viewController.view {
            activityViewController.popoverPresentationController?.sourceView = view
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
                
        viewController.present(activityViewController, animated: true) {
            
        }
        activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            completion()
        }
    }
    
}

final public class MessageWithSubject: NSObject, UIActivityItemSource {
    
    private let url: URL
    private let subject: String
    private let message: String
    private let messageShort: String
    
    public init(subject: String, message: String, messageShort: String? = nil, url: URL) {
        self.subject = subject
        self.message = message
        self.messageShort = messageShort ?? message
        self.url = url
        super.init()
    }
    
    public convenience init(shareable: Shareable) {
        self.init(subject: shareable.subject, message: shareable.message, messageShort: shareable.messageShort, url: shareable.url)
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if let activityType = activityType {
            switch activityType {
            case .postToTwitter:
                return "\(messageShort)\n\n \(url.absoluteString)"
            default:
                return "\(message)\n\n \(url.absoluteString)"
            }
        } else {
            return "\(message)\n\n \(url.absoluteString)"
        }        
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}
