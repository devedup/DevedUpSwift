//
//  File.swift
//  
//
//  Created by David Casserly on 07/09/2020.
//

import Foundation
import UIKit

public class AlignableImageView: UIImageView {

    public enum HorizontalAlignment: String {
        case left, center, right
    }

    enum VerticalAlignment: String {
        case top, center, bottom
    }

    // MARK: Properties

    private var vertical: VerticalAlignment = .center
    private var horizontal: HorizontalAlignment = .center
    
    @IBInspectable
    var verticalAlignment: String {
        set (key) {
            guard let verticalAlignment = VerticalAlignment(rawValue: key) else {
                preconditionFailure()
            }
            vertical = verticalAlignment
        }
        get {
            return vertical.rawValue
        }
    }
        
    @IBInspectable
    var horizontalAlignment: String {
        set (key) {
            guard let horizontalAlignment = HorizontalAlignment(rawValue: key) else {
                preconditionFailure()
            }
            horizontal = horizontalAlignment
        }
        get {
            return horizontal.rawValue
        }
    }
    
    // MARK: Overrides

    public override var image: UIImage? {
        didSet {
            updateContentsRect()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateContentsRect()
    }

    // MARK: Content layout

    private func updateContentsRect() {
        var contentsRect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))

        guard let imageSize = image?.size else {
            layer.contentsRect = contentsRect
            return
        }

        let viewBounds = bounds
        let imageViewFactor = viewBounds.size.width / viewBounds.size.height
        let imageFactor = imageSize.width / imageSize.height

        if imageFactor > imageViewFactor {
            // Image is wider than the view, so height will match
            let scaledImageWidth = viewBounds.size.height * imageFactor
            var xOffset: CGFloat = 0.0

            switch horizontal {
            case .left:
                xOffset = -(scaledImageWidth - viewBounds.size.width) / 2
            case .right:
                xOffset = (scaledImageWidth - viewBounds.size.width) / 2
            default:
                break
            }

            contentsRect.origin.x = xOffset / scaledImageWidth
        }
        else {
            let scaledImageHeight = viewBounds.size.width / imageFactor
            var yOffset: CGFloat = 0.0

            switch vertical {
            case .top:
                yOffset = -(scaledImageHeight - viewBounds.size.height) / 2
            case .bottom:
                yOffset = (scaledImageHeight - viewBounds.size.height) / 2
            default:
                break
            }

            contentsRect.origin.y = yOffset / scaledImageHeight
        }

        layer.contentsRect = contentsRect
    }

}
