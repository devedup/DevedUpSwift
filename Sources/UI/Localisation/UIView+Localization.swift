import Foundation
import UIKit

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
