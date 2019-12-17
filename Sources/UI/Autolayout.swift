//
//  UIView+Autolayout.swift
//
//  Created by David Casserly on 01/05/2018.
//

import UIKit

extension UIView {
    
    /// Convenience method to centre this view in its superview
    public func pinToSuperview() {
        guard let superview = self.superview else {
            preconditionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `pinToSuperview()` to fix this.")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    /// Convenience method to centre this view in its superview
    public func centreInSuperview() {
        guard let superview = self.superview else {
            preconditionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `centreInSuperview()` to fix this.")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let x = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let y = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        
        NSLayoutConstraint.activate([x, y])
    }
    
}
