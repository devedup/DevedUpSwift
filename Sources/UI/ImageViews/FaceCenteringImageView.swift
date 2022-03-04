//
//  FaceCenteringImageView.swift
//  Fitafy
//
//  Created by David Casserly on 10/09/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FaceCenteringImageView: UIView {
    
    public private (set) var heightConstraint: NSLayoutConstraint!
        
    public var debugFace = false // This doesn't work
    private var debugFaceOverlay: UIView?
    
    public private (set) var imageView: UIImageView!
    
    @IBInspectable
    public var rounded: Bool = false
    
    public var faceBoundingBox: CGRect = CGRect.zero
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        let width = self.frame.width
        let height = width // We start off with square images
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        heightConstraint.priority = .defaultLow
        //imageView.pinToSuperview()
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        translatesAutoresizingMaskIntoConstraints = false
        
        clipsToBounds = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        //print(self.bounds)
        if(!faceBoundingBox.isEmpty) {
            centerFace()
        } else {
            // just do this if not centering
            scaleImageToFill(isFaceCentering: false)
            //imageView.contentMode = .scaleAspectFill
            //imageView.frame = self.bounds
        }
        
        if rounded {
            self.layer.cornerRadius = self.bounds.width / 2
            self.clipsToBounds = true
        }
    }

    @discardableResult
    private func scaleImageToFill(isFaceCentering: Bool) -> CGSize {
        guard let image = image else {
            return CGSize.zero
        }
        // Find which is the biggest aspect ratio
        let widthAspect = bounds.size.width / image.size.width
        let heightAspect = bounds.size.height / image.size.height
        
        let aspectRatio: CGFloat = max(widthAspect, heightAspect)
        
        // Calculate what the relative width of the photo is going to be once
        // scaled into the imageView
        let scaledPhotoWidth = image.size.width * aspectRatio
        let scaledPhotoHeight = image.size.height * aspectRatio
//        print("Photo height \(scaledPhotoHeight)")
        
        // If no face data and we display in main position, we want to center the photo in its frame
        // otherwise the x position is 0 - we don't center on face and sometimes the face is offset
        // This happens when there are multiple faces in one photo, but usually they're in the middle of
        // the photo - so ideally we center the photo in the frame, and usually it would be correct
        var x: CGFloat = 0
        var y: CGFloat = 0
        if !isFaceCentering {
            x = (bounds.size.width - scaledPhotoWidth) / 2.0
            y = (bounds.size.height - scaledPhotoHeight) / 2.0
        }
        
        // Frame the image
        imageView.frame = CGRect(x: x, y: y, width: scaledPhotoWidth, height: scaledPhotoHeight)
        
        heightConstraint.constant = scaledPhotoHeight
        setNeedsUpdateConstraints()
        return CGSize(width: scaledPhotoWidth, height: scaledPhotoHeight)
    }
    
    private func centerFace() {
        let faceFrame = self.faceBoundingBox
        
        let scaledSize = scaleImageToFill(isFaceCentering: true)
        let scaledPhotoWidth = scaledSize.width
        let scaledPhotoHeight = scaledSize.height
            
        // Find the face centers on the image
        let faceCenterX = scaledPhotoWidth * faceFrame.midX
        let faceCenterY = scaledPhotoHeight * faceFrame.midY
//        print("Face center y \(faceCenterY)")
//        print("Face max y \(scaledPhotoHeight * faceFrame.maxY)")
        
        // Fix the center of the container
        let containerMidX = bounds.midX
        let containerMidY = bounds.midY
//        print(frame)
//        print("Container mid y \(containerMidY)")
        
        // Find the position of the photo
        var photoX = containerMidX - faceCenterX
        var photoY = containerMidY - faceCenterY
//        print("Photo Y \(photoY)")
        
        // Find the limits
        let limitX = bounds.maxX - scaledPhotoWidth
        let limitY = bounds.maxY - scaledPhotoHeight
        
        // Ensure we don't move it outside the bounds
        photoX = min(max(photoX, limitX), 0)
        photoY = min(max(photoY, limitY), 0)
        
        // Position the photo
        imageView.frame = CGRect(x: photoX, y: photoY, width: scaledPhotoWidth, height: scaledPhotoHeight)
        
        // Show an overlay of where the face is if debugging
        if debugFace {
            if(debugFaceOverlay == nil) {
                debugFaceOverlay = UIView()
                addSubview(debugFaceOverlay!)
                debugFaceOverlay?.backgroundColor = .green.withAlphaComponent(0.3)
            }
            
            let x = (scaledPhotoWidth * faceFrame.minX) - photoX
            let y = (scaledPhotoHeight * faceFrame.minY) - photoY
            let width = scaledPhotoWidth * faceFrame.width
            let height = scaledPhotoHeight * faceFrame.height
            
            let boundingBoxAbsolute = CGRect(x: x, y: y, width: width, height: height)
            debugFaceOverlay?.frame = boundingBoxAbsolute
        }
                
    }
}
