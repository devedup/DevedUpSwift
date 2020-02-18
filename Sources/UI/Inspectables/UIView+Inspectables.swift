import Foundation
import UIKit

//@IBDesignable
public extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        set (width) {
            self.layer.borderWidth = width
        }
        get {
            return self.layer.borderWidth
        }
    }
    
}
