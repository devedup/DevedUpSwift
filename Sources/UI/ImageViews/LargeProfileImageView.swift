//
//  LargeProfileImageView.swift
//  Fitafy
//
//  Created by David Casserly on 10/09/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class LargeProfileImageView: UIImageView {
    
    public private (set) var heightConstraint: NSLayoutConstraint!
    
    public var onImageStartedZooming: ( () -> Void )?
    public var onImageEndedZooming: ( () -> Void )?
    public var faceBoundingBox: CGRect = CGRect.zero
    
//    private var activityIndicator: UIActivityIndicatorView?
    
    public init() {
        super.init(image: nil)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        let width = self.frame.width
        let height = width // We start off with square images
        
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        faceBoundingBox = CGRect.zero
        
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        addSubview(activityIndicator)
//        activityIndicator.centreInSuperview()
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.tintColor = .darkGray
//        self.activityIndicator = activityIndicator
    }
    
//    public override func startAnimating() {
//        activityIndicator?.startAnimating()
//    }
//
//    public override func stopAnimating() {
//        activityIndicator?.stopAnimating()
//    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        //print(self.bounds)
        if(!faceBoundingBox.isEmpty) {
            centerFace()
        }
    }
    
    private func centerFace() {
        guard let image = image else {
            return
        }
            
        print("Centering face")

        let faceFrame = self.faceBoundingBox
        // Find which is the biggest aspect ratio
        let widthAspect = bounds.size.width / image.size.width
        let heightAspect = bounds.size.height / image.size.height
        let aspectRatio: CGFloat = max(widthAspect, heightAspect)
        
        // Calculate what the relative width of the photo is going to be once
        // scaled into the imageView
        let scaledPhotoWidth = image.size.width * aspectRatio
        let scaledPhotoHeight = image.size.height * aspectRatio
        
        // Find between 0-1 where is the centre of the face
        let faceCenterXPercent = faceFrame.minX + (faceFrame.width / 2)
        let faceCenterYPercent = faceFrame.minY + (faceFrame.height / 2)
        
        // Now we have the width, see the pixel position of the centre of the face
        let faceCenterX = scaledPhotoWidth * faceCenterXPercent
        let faceCenterY = scaledPhotoWidth * faceCenterYPercent
        
        // As the image is clipped off screen left and right, calculate what one
        // side of the clipped edge width actually is
        let clippedEdgeWidth = (scaledPhotoWidth - bounds.size.width) / 2
        let clippedEdgeHeight = (scaledPhotoHeight - bounds.size.height) / 2
        
        // Find the centre x of the scaled photo
        let scaledPhotoCenterX: CGFloat = scaledPhotoWidth / 2
        let scaledPhotoCenterY: CGFloat = scaledPhotoHeight / 2
        // Determine how much we have to move to get the face to the middle of the scale photo
        // if the face is to the right, this will be a negative number
        var movePhotoHorizontallyBy: CGFloat = abs(scaledPhotoCenterX - faceCenterX)
        var movePhotoVerticallyBy: CGFloat = abs(scaledPhotoCenterY - faceCenterY)
        // We don't want to move the photo more than the clipped width, otherwise
        // it goes past the edge of the photo. So whichever is smaller
        movePhotoHorizontallyBy = min(clippedEdgeWidth, movePhotoHorizontallyBy)
        movePhotoVerticallyBy = min(clippedEdgeHeight, movePhotoVerticallyBy)
        
        // If the face is to the right of center, need to negate the number
        let isFaceLeftOfCenter = faceCenterXPercent < 0.5 // otherwise it's to the right
        let isFaceAboveCenter = faceCenterYPercent < 0.5
        
        let translateHorizontallyBy = isFaceLeftOfCenter ? movePhotoHorizontallyBy : -movePhotoHorizontallyBy
        let trasnlateVerticallyBy = isFaceAboveCenter ? movePhotoVerticallyBy : -movePhotoVerticallyBy
                
        // Now transform the image (well actually the ImageView frame
        // I'd rather move the image inside the frame ???.. how?
        self.transform = CGAffineTransform(translationX: translateHorizontallyBy,
                                           y: trasnlateVerticallyBy)
        self.clipsToBounds = false
    }
}

extension LargeProfileImageView: ZoomableImage {
    
    public func imageStartedZooming() {
        onImageStartedZooming?()
    }
    
    public func imageStoppedZooming() {
        onImageEndedZooming?()
    }
}
