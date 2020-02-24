import Foundation
import UIKit


public protocol DevedupInspectable {
    var cornerRadius: CGFloat { get set }
    var borderWidth: CGFloat { get set }
}

extension DevedupInspectable where Self:UIView {
//    @IBInspectable
    var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
//    @IBInspectable
    var borderWidth: CGFloat {
        set (width) {
            self.layer.borderWidth = width
        }
        get {
            return self.layer.borderWidth
        }
    }
}
