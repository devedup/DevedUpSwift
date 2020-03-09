import Foundation
import UIKit

public protocol DevedupInspectable {
    var cornerRadius: CGFloat { get set }
    var borderWidth: CGFloat { get set }
}

extension DevedupInspectable where Self:UIView {
    var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    var borderWidth: CGFloat {
        set (width) {
            self.layer.borderWidth = width
        }
        get {
            return self.layer.borderWidth
        }
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
}
