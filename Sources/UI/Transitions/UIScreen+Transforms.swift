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
    
    public func transformBelowCurrentScreen(completion: @escaping () -> Void) {
        guard let superview = self.superview else {
            return
        }
        let parentHeight = superview.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: parentHeight)
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
