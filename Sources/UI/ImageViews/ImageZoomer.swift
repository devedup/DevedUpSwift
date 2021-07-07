//
//  ImageZoomer.swift
//  Fitafy
//
//  Created by David Casserly on 14/09/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    public static let imageZoomerStartedZooming = Notification.Name("imageZoomerStartedZooming")
    public static let imageZoomerEndedZooming = Notification.Name("imageZoomerEndedZooming")
}

public protocol ZoomableImage {
    func imageStartedZooming()
    func imageStoppedZooming()
}

public final class ImageZoomer: UIView {
    
    private let darkBackground = UIView()
    private let zoomingImageView = LargeProfileImageView()
    
    public var onDidStartZooming: (() -> Void)?
    public var onDidEndZooming: (() -> Void)?
    
    private var imageViewFrame: CGRect = CGRect.zero
    private var originalCentrePosition: CGPoint = CGPoint.zero
    
    public var isZoomingEnabled = true
    
    // Yes i need a new one each time for each image view that is added
    private var pinchGesture: UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleZoom))
        pinch.delegate = self
        return pinch
    }
    
    // Yes i need a new one each time for each image view that is added
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
        darkBackground.alpha = 0.0
        self.addSubview(zoomingImageView)
        zoomingImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        zoomingImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        zoomingImageView.frame = imageViewFrame
    }
    
    public func addZoomGestures(imageView: UIImageView & ZoomableImage) {
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
        //print(gestureRecognizer)
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
        guard let imageView = gesture.view as? (LargeProfileImageView & ZoomableImage) else {
            return
        }
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.25) {
                self.darkBackground.alpha = 1.0
            }
            self.adjustAnchorPointForGestureRecognizer(gesture)
            imageView.imageStartedZooming()
            onDidStartZooming?()
            NotificationCenter.default.post(name: .imageZoomerStartedZooming, object: self)
            resizeZoomerImageViewWith(imageView: imageView)
            alpha = 1
        case .changed:
            // Only zoom out to the scale of the frame
            let frameScale = imageView.bounds.size.width / imageView.bounds.size.height
            if gesture.scale >= frameScale {
                let scale = gesture.scale
                self.zoomingImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        default:
            imageView.imageStoppedZooming()
            onDidEndZooming?()
            NotificationCenter.default.post(name: .imageZoomerEndedZooming, object: self)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.zoomingImageView.transform = .identity
            }, completion: { _ in
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 0.0
                    self.darkBackground.alpha = 0.0
                }
            })
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? (LargeProfileImageView & ZoomableImage) else {
            return
        }
        switch gesture.state {
        case .began:
            imageView.imageStartedZooming()
            onDidStartZooming?()
            NotificationCenter.default.post(name: .imageZoomerStartedZooming, object: self)
            self.originalCentrePosition = self.zoomingImageView.center
        case .changed:
            // Get the touch position
            let translation = gesture.translation(in: imageView)
            let zoomView = self.zoomingImageView
            zoomView.center = CGPoint(x: zoomView.center.x + translation.x, y: zoomView.center.y + translation.y)
            gesture.setTranslation(.zero, in: imageView)
        default:
            imageView.imageStoppedZooming()
            onDidEndZooming?()
            NotificationCenter.default.post(name: .imageZoomerEndedZooming, object: self)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.zoomingImageView.center = self.originalCentrePosition
                gesture.setTranslation(.zero, in: imageView)
            }, completion: nil)
        }
    }
}
