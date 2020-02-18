import UIKit

extension UIViewController {
    
    @available(*, deprecated, message: "Use isModal() instead")
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
