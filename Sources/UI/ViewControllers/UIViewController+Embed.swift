//
//  UIViewController+Embed.swift
//
//  Created by David Casserly on 14/06/2018.
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func embedChildViewController(_ childVC: UIViewController, container: UIView) {
        addChild(childVC)
        container.addSubview(childVC.view)
        childVC.view.pinToSuperview()
        childVC.didMove(toParent: self)
    }
    
    public func disembedChildViewController(_ childVC: UIViewController) {
        childVC.didMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
    
}
