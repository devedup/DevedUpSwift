//
//  UIViewController+SegueHandling.swift
//
//  Created by David Casserly on 08/08/2017.
//  Copyright © 2017 DevedUp. All rights reserved.
//

import Foundation
import UIKit

/// I pass this in performSegue(withIdentifier: sender:) as the sender argument. I could just pass the object directly, but that smelt funny. I dunno. This gives a bit more flexibility.
@available(iOS, deprecated: 13, message: "Stop doing this, as we never use the sender param anyway use @IBSegueAction")
public struct SegueData<T> {
    
    public let sender: Any
    public let data: T
    
    public init(sender: Any, data: T) {
        self.sender = sender
        self.data = data
    }
    
}


/// Uses the Swift type system for handling segues, instead of strings which can be mistyped
public protocol Segueable {
    
    associatedtype Segue: RawRepresentable
    func segueIdentifierCase(for segue: UIStoryboardSegue) -> Segue
    
}

@available(iOS, deprecated: 13, message: "This was code for pre iOS 13. In iOS 13 Xcode 11 onwards, we can refactor to use @IBSegueAction")
public protocol SegueableDestination {
    
    associatedtype SegueParams: Any
    func injectSegueDestination(with params: SegueParams)
    
}

// https://useyourloaf.com/blog/better-storyboards-with-xcode-11/
extension Segueable where Self: UIViewController, Segue.RawValue == String {
    
    public func segueIdentifierCase(for segue: UIStoryboardSegue) -> Segue {
        guard let identifier = segue.identifier,
            let identifierCase = Segue(rawValue: identifier) else {
                fatalError("You've used a segue string [\(String(describing: segue.identifier))] that is not a case in your ViewControllerSegue enum")
        }
        return identifierCase
    }
	
	public func perform(_ segue: Segue) {
		performSegue(withIdentifier: segue.rawValue, sender: self)
	}
    
    @available(iOS, deprecated: 13, message: "Don't use this anymore - refactor to use @IBSegueAction")
    public func perform<T>(_ segue: Segue, data: SegueData<T>) {
        performSegue(withIdentifier: segue.rawValue, sender: data)
    }
    
    @available(iOS, deprecated: 13, message: "Don't use this anymore - refactor to use @IBSegueAction")
    public func perform<T>(_ segue: Segue, withData data: T) {
        performSegue(withIdentifier: segue.rawValue, sender: data)
    }
    
}

extension UIStoryboardSegue {
    
    /// Returns the destinatino ViewController or the topViewController if it's embedded in a UINavigationController
    public func viewController<T: UIViewController>() -> T? {
        if let navigationController = self.destination as? UINavigationController {
            return navigationController.topViewController as? T
        } else {
            return self.destination as? T
        }
    }
    
    public func segueableDestination<T: UIViewController & SegueableDestination>() -> T? {
        if let navigationController = self.destination as? UINavigationController {
            return navigationController.topViewController as? T
        } else {
            return self.destination as? T
        }
    }
    
}
