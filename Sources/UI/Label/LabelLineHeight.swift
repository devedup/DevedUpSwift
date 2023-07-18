// Created by David Casserly on 11/07/2023.
// Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import Foundation
import UIKit

public extension UILabel {
    
    @IBInspectable var lineHeight: CGFloat {
        set(newLineHeight) {
            let attributedText = NSMutableAttributedString(string: text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.0
            paragraphStyle.lineHeightMultiple = newLineHeight
            paragraphStyle.alignment = textAlignment

            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length - 1))

            self.attributedText = attributedText
        }
        get {
            return self.lineHeight
        }
    }
    
}

