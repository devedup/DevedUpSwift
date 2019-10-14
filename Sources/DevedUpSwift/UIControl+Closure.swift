//
//  File.swift
//  
//
//  Created by David Casserly on 14/10/2019.
//
import UIKit

extension UIControl {
    
    public func addAction(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let wrapper = ClosureWrapper(closure)
        addTarget(wrapper, action: #selector(ClosureWrapper.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "[\(arc4random())]", wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
}
