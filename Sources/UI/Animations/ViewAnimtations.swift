//
//  File.swift
//  
//
//  Created by David Casserly on 28/02/2022.
//

import Foundation
import UIKit

extension UIView {

    public func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [ -20, 20, -20, 20, -10, 10, -5, 5, 0]
        self.layer.add(animation, forKey: "shake")
    }
    
    public func pulse() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0.95, 0.95, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.05, 1.05, 1.0))
        animation.autoreverses = true
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime()
        self.layer.add(animation, forKey: "pulse")
    }
    
    public func stopPulse() {
        self.layer.removeAnimation(forKey: "pulse")
    }
    
}
