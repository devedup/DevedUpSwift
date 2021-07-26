//
//  AudioRings.swift
//  ShazamLikeAnimation
//
//  Created by David Casserly on 17/05/2018.
//  Copyright © 2018 DevedUp. All rights reserved.
//

import Foundation
import UIKit

private let PulseAnimation = "PulseAnimation"
private let CompletionBlock = "CompletionBlock"
private let PulseWaveAnimation = "BigPulseAnimation"

public class PulsatingRingsView: UIView {
     
    private let circleIntervalDuration = 0.9    // How often we create a new circle
    private var logoPulseDuration: Double {
        return circleIntervalDuration / 2.0 // Half of the cirlce duration, as it pulses in and out
    }
    private let circleExpandDuration = 2.0      // How long it take the circle to get big
    private var timer: Timer?
    
    @IBInspectable public var mainColor: UIColor = .red
    @IBInspectable public var centreImage: UIImage? {
        didSet {
            logoImageView?.image = centreImage
        }
    }
    
    // Created on init
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var logoImageView: UIImageView!
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        self.contentMode = .redraw;
        self.backgroundColor = UIColor.clear
        
        let logoImageView = UIImageView(image: centreImage) // centre image is actually nil at this point
        self.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.centreInSuperview()
        self.logoImageView = logoImageView
    }
    
    // MARK: Colors
    
    private var mainColorAnimated: UIColor {
        return mainColor.withAlphaComponent(0.7)
    }
    private var alternateColor: UIColor {
        return mainColor.withAlphaComponent(0.5)
    }
    
    // MARK: Dimensions
    
    /// The rect of the circle in the center of the view
    private var centerCircleRect: CGRect {
        let circleDiameter = self.bounds.size.width
        let centerCircleRect = CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter)
        return centerCircleRect
    }
    
    // MARK: Actions
    
    /// Stop pulsating centre and draw an expanding circle every second
    public func startPulsating() {
        makePulsatingWavingCircle()
        timer = Timer.scheduledTimer(withTimeInterval: circleIntervalDuration, repeats: true) {
            [weak self] (_) in
            self?.makePulsatingWavingCircle()
        }
        logoImageView.layer.add(pulseAnimation(), forKey: PulseAnimation)
    }
    
    public func stopPulsating() {
        removeCurrentRings()
        timer?.invalidate()
        timer = nil
        logoImageView.layer.removeAnimation(forKey: PulseAnimation)
    }
    
    private func removeCurrentRings() {
        currentRings.forEach{ $0.removeFromSuperview() }
        currentRings.removeAll()
    }
    
    private var currentRings = [Ring]()
    
    // MARK: Animations
    private var shouldAlternateColor = false
    
    private func makePulsatingWavingCircle() {
        let ringColour = shouldAlternateColor ? alternateColor : mainColorAnimated
        shouldAlternateColor = !shouldAlternateColor
        let ring = makeRing(withColor: ringColour)
        currentRings.append(ring)
        
        let animation = bigPulseFadeAnimation()
        let completion = {
            ring.removeFromSuperview()
        } // completion block
        animation.setValue(completion, forKey: CompletionBlock)
        ring.layer.add(animation, forKey: PulseWaveAnimation)
    }
    
    private func makeRing(withColor color: UIColor) -> Ring {
        let ring = Ring(frame: centerCircleRect)
        ring.colour = color
        insertSubview(ring, belowSubview: logoImageView)
        ring.centreInSuperview()
        ring.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        ring.heightAnchor.constraint(equalTo: ring.widthAnchor).isActive = true
        return ring
    }
    
    // These are the big circles that start at bottom and fade out and get big
    private func bigPulseFadeAnimation() -> CAAnimation {
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(4, 4, 1.0))
        transformAnimation.autoreverses = true
        transformAnimation.duration = circleExpandDuration
    
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.toValue = 0.0
        alphaAnimation.autoreverses = false
        alphaAnimation.duration = circleExpandDuration
    
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [transformAnimation, alphaAnimation]
        animationGroup.duration = circleExpandDuration
        animationGroup.beginTime = CACurrentMediaTime()
        animationGroup.delegate = self
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.fillMode = CAMediaTimingFillMode.both
        animationGroup.isRemovedOnCompletion = false
        return animationGroup
    }
    
    private func pulseAnimation() -> CAAnimation {
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1.0))
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0))
        transformAnimation.autoreverses = true
        transformAnimation.duration = logoPulseDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transformAnimation.repeatCount = .infinity
        transformAnimation.beginTime = CACurrentMediaTime()
        return transformAnimation
    }
    
}

extension PulsatingRingsView: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completionBlock: () -> Void = anim.value(forKey: CompletionBlock) as? () -> Void {
            completionBlock()
        }
    }
    
}


/// One circle that fills it's bounds. Clear background
fileprivate class Ring: UIView {
    
    var colour: UIColor!

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        self.contentMode = .redraw;
        self.backgroundColor = .clear
        self.colour = .white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // potentially could always draw 2 rings here, the red ring and the transparent ring instead of using the stop button with the blue background
        
        // Setup context
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setShouldAntialias(true);
        ctx.setAllowsAntialiasing(true);
        
        // Draw outer black circle
        colour.setFill()
        ctx.fillEllipse(in: bounds)
    }
    
}
