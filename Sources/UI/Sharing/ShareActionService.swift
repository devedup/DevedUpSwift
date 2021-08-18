//
//  ShareActionService.swift
//  ManchesterFC
//
//  Created by David Casserly on 08/05/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public protocol ShareActionService {
    func share(message: MessageWithSubject, from viewController: UIViewController, completion: @escaping () -> Void)
}

final public class DefaultShareActionService: ShareActionService {
    
    public static let sharedInstance = DefaultShareActionService()
    
    private init() {}
    
    public func share(message: MessageWithSubject, from viewController: UIViewController, completion: @escaping () -> Void) {
        let activityViewController =
            UIActivityViewController(activityItems: [message],
                                     applicationActivities: nil)
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
    
    public init(subject: String, message: String, url: URL) {
        self.subject = subject
        self.message = message
        self.url = url
        super.init()
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "\(message)\n\n \(url.absoluteString)"
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}
