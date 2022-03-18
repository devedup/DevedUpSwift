//
//  File.swift
//  
//
//  Created by David Casserly on 08/04/2020.
//

import Foundation
import UIKit

public class BadgeLabel: UILabel {
        
    //@IBInspectable public var circleColour: UIColor = UIColor.black
    
    private let insets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    
    public var borderColour: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
        layer.borderWidth = 2
        layer.borderColor = borderColour.cgColor
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
    
    public var count: Int = 0 {
        didSet {
            if count <= 0 {
                text = ""
                isHidden = true
            } else {
                if count > 99 {
                    text = "99"
                } else {
                    text = "\(count)"
                }
                isHidden = false
            }
        }
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        circleLayer.frame = bounds
//    }
//
//    public lazy var circleLayer: CAShapeLayer = {
//        let circleLayer = CAShapeLayer()
//        circleLayer.frame = self.bounds
//        let radius: CGFloat = self.bounds.size.width / 2
//        circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
//        circleLayer.fillColor = circleColour.cgColor
//        layer.insertSublayer(circleLayer, at: 0)
//        return circleLayer
//    }()

}
