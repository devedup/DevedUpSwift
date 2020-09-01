//
//  File.swift
//  
//
//  Created by David Casserly on 04/08/2020.
//

import Foundation
import UIKit

//@IBDesignable
open class GradientRoundedButton: UIButton {
     
    @IBInspectable public var leftColour: UIColor = UIColor.white {
        didSet {
            clipsToBounds = true
        }
    }
    
    @IBInspectable public var rightColour: UIColor = UIColor.black {
        didSet {
            clipsToBounds = true
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    open override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    private func sharedInit() {        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    public lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [leftColour.cgColor, rightColour.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        //l.cornerRadius = 16
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
}
