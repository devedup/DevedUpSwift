//  Created by David Casserly on 09/07/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    public static func topViewController() -> UIViewController? {
        // swiftlint:disable:next first_where
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?
                .windows
                .filter({$0.isKeyWindow})
                .first
        
        var top = keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
    
}

extension UIViewController {
    public func topViewControllerInNavOrSelf<T: UIViewController>() -> T? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? T
        } else {
            return self as? T
        }
    }
}
