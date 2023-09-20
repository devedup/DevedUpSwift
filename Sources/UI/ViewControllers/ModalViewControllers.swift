import UIKit

extension UIViewController {
    
    public var isTopOfNavigationStack: Bool {
        guard let navigationController = self.navigationController else {
            return false
        }
        return navigationController.viewControllers.first == self ? true : false
    }
    
    public var isInsideModalPresentation: Bool {
        if self.presentingViewController != nil {
            return true
        }
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
}

// DEPRECATED
extension UIViewController {
    
    @objc
    @available(*, deprecated, message: "Use isInsideModalPresentation")
    public func wasPresentedModally() -> Bool {
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
        if self.presentingViewController != nil {
            return true
        }
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
    @objc
    @available(*, deprecated, message: "Use isInsideModalPresentation")
    public func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        }
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
}
