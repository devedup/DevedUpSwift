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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        leftPadding = 25
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        super.drawText(in: rect.inset(by:insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let horizontalPadding = leftPadding + rightPadding
        let verticalPadding = topPadding + bottomPadding
        return CGSize(width: size.width + horizontalPadding,
                      height: size.height + verticalPadding)
    }
    
}
