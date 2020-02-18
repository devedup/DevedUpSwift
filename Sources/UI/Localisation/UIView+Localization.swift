import Foundation
import UIKit

@IBDesignable
public extension UILabel {
    
    @IBInspectable
    var l18nKey: String {
        set (key) {
            self.text = key.localized
        }
        get {
            return self.l18nKey
        }
    }
    
}

@IBDesignable
public extension UITextField {
    
    @IBInspectable
    var l18nPlaceholder: String {
        set (key) {
            self.placeholder = key.localized
        }
        get {
            return self.l18nPlaceholder
        }
    }
    
}

@IBDesignable
public extension UIButton {
    
    @IBInspectable
    var l18nKey: String {
        set (key) {
            self.setTitle(key.localized, for: .normal)
        }
        get {
            return self.l18nKey
        }
    }
    
}
