//
//  UIScreen+Transforms.swift
//  SimbaSleep
//
//  Copyright © 2018 SimbaSleep. All rights reserved.
//

import UIKit

extension UIView {
    
//    public func currentScreenRect() -> CGRect {
//        return UIScreen.main.bounds
//    }
//
//    public func transformLeftOfCurrentScreen() -> CGAffineTransform {
//        let screen = currentScreenRect()
//        return CGAffineTransform(translationX: -screen.width, y: 0)
//    }
//
//    public func transformRightOfCurrentScreen() -> CGAffineTransform {
//        let screen = currentScreenRect()
//        return CGAffineTransform(translationX: screen.width, y: 0)
//    }
//
//    public func transformAboveCurrentScreen() -> CGAffineTransform {
//        let screen = currentScreenRect()
//        return CGAffineTransform(translationX: 0, y: -screen.height)
//    }
    
    public func transformBelowCurrentScreen(animated: Bool = true, completion: @escaping () -> Void) {
        guard let superview = self.superview else {
            return
        }
        let parentHeight = superview.frame.height
        
        let newTransform = CGAffineTransform(translationX: 0, y: parentHeight)
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.transform = newTransform
            } completion: { success in
                completion()
            }
        } else {
            self.transform = newTransform
            completion()
        }        
    }
    
    public func transformToPoint(animated: Bool = true, with: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            with()
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001);
        } completion: { success in
            completion()
        }
    }
    
}

extension UIScreen {
    
    public func currentScreenRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    public func transformLeftOfCurrentScreen() -> CGAffineTransform {
        let screen = currentScreenRect()
        return CGAffineTransform(translationX: -screen.width, y: 0)
    }
    
    public func transformRightOfCurrentScreen() -> CGAffineTransform {
        let screen = currentScreenRect()
        return CGAffineTransform(translationX: screen.width, y: 0)
    }
    
    public func transformAboveCurrentScreen() -> CGAffineTransform {
        let screen = currentScreenRect()
        return CGAffineTransform(translationX: 0, y: -screen.height)
    }
    
    public func transformBelowCurrentScreen() -> CGAffineTransform {
        let screen = currentScreenRect()
        return CGAffineTransform(translationX: 0, y: screen.height)
    }
    
}

extension UITabBarController {
    
    public func transformToNormalPosition() {
        tabBar.transform = CGAffineTransform.identity
    }
    
    public func transformBelowCurrentScreen() {
        let frame = tabBar.frame
        let height = frame.size.height
        tabBar.transform = CGAffineTransform(translationX: 0, y: height)
    }
    
}
