//  UINavigationController+Additions.swift

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    
    /// Custom back buttons disable the interactive pop animation
    /// To enable it back we set the recognizer to `self`
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
}
