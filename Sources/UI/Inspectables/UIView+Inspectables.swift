import Foundation
import UIKit

public protocol DevedupInspectable {
    var cornerRadius: CGFloat { get set }
    var borderWidth: CGFloat { get set }
}

extension DevedupInspectable where Self:UIView {
    public var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    public var borderWidth: CGFloat {
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
    public var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
        }
        get {
            return self.layer.cornerRadius
        }
    }
}
