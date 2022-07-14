//
//  UIView+Autolayout.swift
//
//  Created by David Casserly on 01/05/2018.
//

import UIKit

extension UIView {
    
    public func pinTo(layoutGuide: UILayoutGuide) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
    }
    
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
    
    public func pinVerticallyToSuperview() {
        guard let superview = self.superview else {
            preconditionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `pinToSuperview()` to fix this.")
        }
        translatesAutoresizingMaskIntoConstraints = false
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
    
    public func pinBottoms() {
        guard let superview = self.superview else {
            preconditionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `pinToSuperview()` to fix this.")
        }
        translatesAutoresizingMaskIntoConstraints = false
        //topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: frame.size.height).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
}
