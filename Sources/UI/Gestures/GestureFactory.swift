//  Style.swift
//
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//

import UIKit
import Foundation

public final class GestureFactory {
    
    // MARK: Swipes
    
    @discardableResult
    public class func addRightSwipe(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UISwipeGestureRecognizer? {
        let rightSwipeRecogniser = UISwipeGestureRecognizer(target: target, action: selector)
        rightSwipeRecogniser.delegate = target
        rightSwipeRecogniser.numberOfTouchesRequired = 1
        rightSwipeRecogniser.direction = .right
        if let gesture = gesture {
            rightSwipeRecogniser.require(toFail: gesture)
        }
        view.addGestureRecognizer(rightSwipeRecogniser)
        return rightSwipeRecogniser
    }
    
    @discardableResult
    public class func addRightSwipe(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UISwipeGestureRecognizer? {
        return self.addRightSwipe(to: view, target: target, action: selector, requireGestureToFail: nil)
    }
    
    @discardableResult
    public class func addLeftSwipe(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UISwipeGestureRecognizer? {
        let leftSwipeRecogniser = UISwipeGestureRecognizer(target: target, action: selector)
        leftSwipeRecogniser.delegate = target
        leftSwipeRecogniser.numberOfTouchesRequired = 1
        leftSwipeRecogniser.direction = .left
        if let gesture = gesture {
            leftSwipeRecogniser.require(toFail: gesture)
        }
        view.addGestureRecognizer(leftSwipeRecogniser)
        return leftSwipeRecogniser
    }
    
    @discardableResult
    public class func addLeftSwipe(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UISwipeGestureRecognizer? {
        return self.addLeftSwipe(to: view, target: target, action: selector, requireGestureToFail: nil)
    }
    
    @discardableResult
    public class func addTwoFingerSwipeDown(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UISwipeGestureRecognizer? {
        let swipeGesture = UISwipeGestureRecognizer(target: target, action: selector)
        swipeGesture.delegate = target
        swipeGesture.numberOfTouchesRequired = 2
        swipeGesture.direction = .down
        if let gesture = gesture {
            swipeGesture.require(toFail: gesture)
        }
        view.addGestureRecognizer(swipeGesture)
        return swipeGesture
    }
    
    @discardableResult
    public class func addSwipeDown(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UISwipeGestureRecognizer? {
        let rightSwipeRecogniser = UISwipeGestureRecognizer(target: target, action: selector)
        rightSwipeRecogniser.delegate = target
        rightSwipeRecogniser.numberOfTouchesRequired = 1
        rightSwipeRecogniser.direction = .down
        if let gesture = gesture {
            rightSwipeRecogniser.require(toFail: gesture)
        }
        view.addGestureRecognizer(rightSwipeRecogniser)
        return rightSwipeRecogniser
    }
    
    @discardableResult
    public class func addSwipeUp(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UISwipeGestureRecognizer? {
        let rightSwipeRecogniser = UISwipeGestureRecognizer(target: target, action: selector)
        rightSwipeRecogniser.delegate = target
        rightSwipeRecogniser.numberOfTouchesRequired = 1
        rightSwipeRecogniser.direction = .up
        if let gesture = gesture {
            rightSwipeRecogniser.require(toFail: gesture)
        }
        view.addGestureRecognizer(rightSwipeRecogniser)
        return rightSwipeRecogniser
    }
    
    // MARK: - Taps
    
    @discardableResult
    public class func addFiveTap(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UITapGestureRecognizer? {
        let doubleTapRecogniser = UITapGestureRecognizer(target: target, action: selector)
        doubleTapRecogniser.delegate = target
        doubleTapRecogniser.numberOfTouchesRequired = 1
        doubleTapRecogniser.numberOfTapsRequired = 5
        view.addGestureRecognizer(doubleTapRecogniser)
        return doubleTapRecogniser
    }
    
    @discardableResult
    public class func addDoubleTap(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UITapGestureRecognizer? {
        let doubleTapRecogniser = UITapGestureRecognizer(target: target, action: selector)
        doubleTapRecogniser.delegate = target
        doubleTapRecogniser.numberOfTouchesRequired = 1
        doubleTapRecogniser.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecogniser)
        return doubleTapRecogniser
    }
    
    @discardableResult
    public class func addSingleTap(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UITapGestureRecognizer? {
        let singleTapRecogniser = UITapGestureRecognizer(target: target, action: selector)
        singleTapRecogniser.delegate = target
        singleTapRecogniser.numberOfTouchesRequired = 1
        singleTapRecogniser.numberOfTapsRequired = 1
        if let gesture = gesture {
            singleTapRecogniser.require(toFail: gesture)
        }
        view.addGestureRecognizer(singleTapRecogniser)
        return singleTapRecogniser
    }
    
    @discardableResult
    public class func addSingleTap(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UITapGestureRecognizer? {
        return self.addSingleTap(to: view, target: target, action: selector, requireGestureToFail: nil)
    }
    
    @discardableResult
    public class func addTouchDown(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> TouchDownGestureRecogniser? {
        let singleTapRecogniser = TouchDownGestureRecogniser(target: target, action: selector)
        singleTapRecogniser.delegate = target
        view.addGestureRecognizer(singleTapRecogniser)
        return singleTapRecogniser
    }
    
    // MARK: - Pan
    
    @discardableResult
    public class func addPan(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, fingers: Int, requireGestureToFail gesture: UIGestureRecognizer?) -> UIPanGestureRecognizer? {
        let panGestureRecognizer = UIPanGestureRecognizer(target: target, action: selector)
        panGestureRecognizer.maximumNumberOfTouches = fingers
        panGestureRecognizer.delegate = target
        view.addGestureRecognizer(panGestureRecognizer)
        if let gesture = gesture {
            panGestureRecognizer.require(toFail: gesture)
        }
        return panGestureRecognizer
    }
    
    @discardableResult
    public class func addPan(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, fingers: Int) -> UIPanGestureRecognizer? {
        return self.addPan(to: view, target: target, action: selector, fingers: fingers, requireGestureToFail: nil)
    }
    
    @discardableResult
    public class func addPan(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector, requireGestureToFail gesture: UIGestureRecognizer?) -> UIPanGestureRecognizer? {
        return self.addPan(to: view, target: target, action: selector, fingers: 1, requireGestureToFail: gesture)
    }
    
    @discardableResult
    public class func addPan(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UIPanGestureRecognizer? {
        return self.addPan(to: view, target: target, action: selector, fingers: 1)
    }
    
    @discardableResult
    public class func addPanTwoFingers(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UIPanGestureRecognizer? {
        return self.addPan(to: view, target: target, action: selector, fingers: 2)
    }
    
    // MARK: - Pinch
    
    @discardableResult
    public class func addPinch(to view: UIView, target: UIGestureRecognizerDelegate?, action selector: Selector) -> UIPinchGestureRecognizer? {
        let pinchGesture = UIPinchGestureRecognizer(target: target, action: selector)
        pinchGesture.delegate = target
        view.addGestureRecognizer(pinchGesture)
        return pinchGesture
    }
    
}
