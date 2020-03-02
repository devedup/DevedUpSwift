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
    
    @available(*, deprecated, message: "Use isInsideModalPresentation")
    open func wasPresentedModally() -> Bool {
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
    
    @available(*, deprecated, message: "Use isInsideModalPresentation")
    open func isModal() -> Bool {
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
