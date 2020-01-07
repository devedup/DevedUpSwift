//
//  UIViewController+SegueHandling.swift
//
//  Created by David Casserly on 08/08/2017.
//  Copyright © 2017 DevedUp. All rights reserved.
//

import Foundation
import UIKit

/// I pass this in performSegue(withIdentifier: sender:) as the sender argument. I could just pass the object directly, but that smelt funny. I dunno. This gives a bit more flexibility. 
public struct SegueData<T> {
    
    let sender: Any
    let data: T
    
}

/// Uses the Swift type system for handling segues, instead of strings which can be mistyped
public protocol Segueable {
    
    associatedtype Segue: RawRepresentable
    func segueIdentifierCase(for segue: UIStoryboardSegue) -> Segue
    
}

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
    
    public func perform<T>(_ segue: Segue, data: SegueData<T>) {
        performSegue(withIdentifier: segue.rawValue, sender: data)
    }
    
}
