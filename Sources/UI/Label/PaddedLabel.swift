//  PaddedLabel.swift
//
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

class PaddedLabel: UILabel {
    
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 0
    @IBInspectable var topPadding: CGFloat = 0
    @IBInspectable var bottomPadding: CGFloat = 0
    
    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        }
        set {
            topPadding = newValue.top
            leftPadding = newValue.left
            bottomPadding = newValue.bottom
            rightPadding = newValue.right
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
            contentSize.width += leftPadding + rightPadding
            contentSize.height += topPadding + bottomPadding
        return contentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjSize = super.sizeThatFits(size)
        adjSize.width += leftPadding + rightPadding
        adjSize.height += topPadding + bottomPadding
        return adjSize
    }
    
}
