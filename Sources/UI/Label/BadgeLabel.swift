//
//  File.swift
//  
//
//  Created by David Casserly on 08/04/2020.
//

import Foundation
import UIKit

public class BadgeLabel: UILabel {
        
    private let insets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/1.0).isActive = true
        clipsToBounds = true
        textAlignment = .center
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = bounds.size.height / 2
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let horizontalPadding = insets.left + insets.right
        let verticalPadding = insets.top + insets.bottom
        return CGSize(width: size.width + horizontalPadding,
                      height: size.height + verticalPadding)
    }
    
    public override var text: String? {
        didSet {
            guard let textFound = text else {
                isHidden = true
                return
            }            
            isHidden = textFound.isEmpty
            if let number = Int(textFound) {
                if number > 9 {
                    text = "9+"
                }
            }
        }
    }


}
