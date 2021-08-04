//
//  File.swift
//  
//
//  Created by David Casserly on 14/09/2020.
//

import Foundation
import UIKit

extension UIView {
    
    public func isVisible(in inView: UIView) -> Bool {
        if self.isHidden || self.superview == nil {
            return false
        }
        let rootView = inView
        let viewFrame = self.convert(self.bounds, to: rootView)
        let container = CGRect(x: 0, y: 0, width: rootView.bounds.width, height: rootView.bounds.height)
        return container.intersects(viewFrame)
    }
    
    public func isVisibleOnScreen() -> Bool {
        // swiftlint:disable:next first_where
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?
                .windows
                .filter({$0.isKeyWindow})
                .first
        
        guard let rootViewController = keyWindow?.rootViewController,
            let rootView = rootViewController.view else {
                return false
        }
        return isVisible(in: rootView)
    }
}
