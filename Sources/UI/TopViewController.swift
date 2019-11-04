//  Created by David Casserly on 09/07/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    public static func topViewController() -> UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
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
