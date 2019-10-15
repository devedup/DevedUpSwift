//  Created by David Casserly on 14/10/2019.
//

import Foundation
import UIKit

extension UIButton {
    
    /// By default the image is on the left of the text, this moves it to the right
    open func moveImageToRight() {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
}
