//
//  ImageZoomer.swift
//  Fitafy
//
//  Created by David Casserly on 14/09/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public final class ImageZoomer: UIView {
    
    private let darkBackground = UIView()
    private let zoomingImageView = LargeProfileImageView()
    
    public var onDidStartZooming: (() -> Void)?
    public var onDidEndZooming: (() -> Void)?
    
    private var imageViewFrame: CGRect = CGRect.zero
    private var originalCentrePosition: CGPoint = CGPoint.zero
    
    public var isZoomingEnabled = true
    
    private var pinchGesture: UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleZoom))
        pinch.delegate = self
        return pinch
    }
    
    private var panGesture: UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.delegate = self
        return pan
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        alpha = 0.0
        backgroundColor = .clear
        isUserInteractionEnabled = false
        self.addSubview(darkBackground)
        darkBackground.pinToSuperview()
        darkBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(zoomingImageView)
        zoomingImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        zoomingImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        zoomingImageView.frame = imageViewFrame
    }
    
    public func addZoomGestures(imageView: UIImageView) {
        imageView.isUserInteractionEnabled = true
        if(imageView.gestureRecognizers?.isEmpty ?? true) {
            imageView.addGestureRecognizer(pinchGesture)
            imageView.addGestureRecognizer(panGesture)
        }
    }
    
    private func resizeZoomerImageViewWith(imageView: LargeProfileImageView)  {
        let sourceFrame = imageView.frame
        let sourceParent = imageView.superview
        let targetView = self
        if let convertedFrame = sourceParent?.convert(sourceFrame, to: targetView) {
            imageViewFrame = convertedFrame
            self.setNeedsLayout()
            zoomingImageView.image = imageView.image
            zoomingImageView.heightConstraint.constant = imageView.heightConstraint.constant
            self.bringSubviewToFront(zoomingImageView)
        }
    }
    
}

extension ImageZoomer: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print(gestureRecognizer)
        return isZoomingEnabled
    }
    
    // that method make it works
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // scale and rotation transforms are applied relative to the layer's anchor point
    // this method moves a gesture recognizer's view's anchor point between the user's fingers
    private func adjustAnchorPointForGestureRecognizer(_ gesture: UIGestureRecognizer) {
        if let view = gesture.view {
            let locationInView = gesture.location(in: view)
            let locationInSuper = gesture.location(in: view.superview)
            self.zoomingImageView.layer.anchorPoint = CGPoint(x: locationInView.x / view.bounds.size.width, y: locationInView.y / view.bounds.size.height)
            self.zoomingImageView.center = locationInSuper
        }
    }
    
    @objc func handleZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view as? LargeProfileImageView else {
            return
        }
        switch gesture.state {
        case .began:
            self.adjustAnchorPointForGestureRecognizer(gesture)
            onDidStartZooming?()
            resizeZoomerImageViewWith(imageView: imageView)
            alpha = 1
        case .changed:
            // Only zoom in, not out
            if gesture.scale >= 1 {
                let scale = gesture.scale
                self.zoomingImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        default:
            onDidEndZooming?()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.zoomingImageView.transform = .identity
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.alpha = 0.0
                }
            })
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? LargeProfileImageView else {
            return
        }
        switch gesture.state {
        case .began:
            onDidStartZooming?()
            self.originalCentrePosition = self.zoomingImageView.center
        case .changed:
            // Get the touch position
            let translation = gesture.translation(in: imageView)
            let zoomView = self.zoomingImageView
            zoomView.center = CGPoint(x: zoomView.center.x + translation.x, y: zoomView.center.y + translation.y)
            gesture.setTranslation(.zero, in: imageView)
        default:
            onDidEndZooming?()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.zoomingImageView.center = self.originalCentrePosition
                gesture.setTranslation(.zero, in: imageView)
            }, completion: nil)
        }
    }
}
