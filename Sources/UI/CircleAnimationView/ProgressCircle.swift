//
//  ProgressCircle.swift
//  Fitafy
//
//  Created by David Casserly on 12/07/2021.
//  Copyright © 2021 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class ProgressCircle: UIView {
    
    @IBInspectable public var circleBackgroundColour: UIColor = UIColor.white
    @IBInspectable public var circleColour: UIColor = UIColor.black
    @IBInspectable public var stroke: Float = 3.0
    
    private var circleLayer: CAShapeLayer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }
    
    private func sharedInit() {
//        backgroundColor = .red
    }
    
    private func bezierPath(for angle: Float) -> UIBezierPath {
        //Angle
        var angle: Float = (360.0 * angle) + 90
        print(angle)
        if (angle < 0) {
            angle = angle + 360
        }
        
        let degrees = Float(Double.pi/180)
        let startAngle = CGFloat(90 * degrees)
        let endAngle = CGFloat(angle * degrees)

        let circleRect = rectForStroke(rect: bounds, stroke: CGFloat(self.stroke))
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let radius = circleRect.size.width / 2
        let arcPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return arcPath
    }
    
    private func rectForStroke(rect: CGRect, stroke: CGFloat) -> CGRect {
        let halfStroke = stroke / 2.0
        return rect.inset(by: UIEdgeInsets(top: halfStroke, left: halfStroke, bottom: halfStroke, right: halfStroke))
    }
    
    public func animate(toAngle angle: Float, completion: (() -> Void)? = nil) {
        let animationKey = "CircleStroke"
        circleLayer?.removeFromSuperlayer()        
        
        CATransaction.begin()
        
        let circleLayer = CAShapeLayer()
        circleLayer.backgroundColor = self.backgroundColor?.cgColor ?? UIColor.white.cgColor
        circleLayer.strokeColor = circleColour.cgColor
        circleLayer.fillColor = nil
        circleLayer.lineWidth = CGFloat(stroke)
        circleLayer.lineCap = .round
        circleLayer.frame = self.bounds

        let path = bezierPath(for: angle)
        circleLayer.path = path.cgPath

        let animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = Double(angle) // all the way around would take 1 second... so duration match angle

        CATransaction.setCompletionBlock{
            completion?()
        }

        circleLayer.add(animation, forKey: animationKey)
        CATransaction.commit()
        
        self.layer.addSublayer(circleLayer)
        self.circleLayer = circleLayer
    }
    
    public func clear() {
        circleLayer?.removeFromSuperlayer()
    }
    
}
