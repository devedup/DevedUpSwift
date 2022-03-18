//
//  CoreAnimationTransition.swift
//  SimbaSleep
//
//  Copyright © 2019 SimbaSleep. All rights reserved.
//

import Foundation
import UIKit

public enum AnimationDirection {
    case up
    case down
    case downOver
    case upOver
}

public class CoreAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.5
    private let direction: AnimationDirection
    private var propertyAnimator: UIViewPropertyAnimator?
    
    public init(direction: AnimationDirection) {
        self.direction = direction
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    public func interruptibleAnimator(using context:
        UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }
        
        // Setup them variables
        guard
            let toView = context.view(forKey: .to),
            let fromView = context.view(forKey: .from),
            let fromViewController = context.viewController(forKey: .from)
        else {
            preconditionFailure()
        }

        // The container view acts as the superview of all other views (including those of the presenting and presented view controllers) during the animation sequence. UIKit sets this view for you and automatically adds the view of the presenting view controller to it. The animator object is responsible for adding the view of the presented view controller, and the animator object or presentation controller must use this view as the container for all other views involved in the transition.
        let containerView = context.containerView
        containerView.addSubview(toView)
        
        // Prepare toVC below or above
        switch direction {
        case .up:
            toView.transform = UIScreen.main.transformBelowCurrentScreen()
        case .down, .downOver:
            toView.transform = UIScreen.main.transformAboveCurrentScreen()
        case .upOver:
            containerView.addSubview(fromView)
        }
        
        // Simple
        let timing = UICubicTimingParameters(animationCurve: .easeInOut)
        
        let animator = UIViewPropertyAnimator(duration:self.duration, timingParameters:timing)
        animator.addAnimations {
            switch self.direction {
            case .up:
                fromView.transform = UIScreen.main.transformAboveCurrentScreen()
            case .upOver:
                fromView.transform = UIScreen.main.transformAboveCurrentScreen()
                fromViewController.tabBarController?.tabBar.alpha = 1.0
            case .down:
                fromView.transform = UIScreen.main.transformBelowCurrentScreen()
            case .downOver:
                fromViewController.tabBarController?.tabBar.alpha = 0.0
            }
            
            toView.transform = CGAffineTransform.identity
        }
        animator.addCompletion { (_) in
            if context.transitionWasCancelled {
                // Need to reset this as it was cancelled
                toView.transform = CGAffineTransform.identity
                toView.removeFromSuperview()
                context.completeTransition(false)
            } else {
                // Reset where we came from because success
                fromView.transform = CGAffineTransform.identity
                context.completeTransition(true)
            }
            // reset animator because the current transition ended
            self.propertyAnimator = nil
        }
        self.propertyAnimator = animator
        return animator
    }

}
