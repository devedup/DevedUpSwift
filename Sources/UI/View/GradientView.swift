//
//  GradientView.swift
//
//  Created by David Casserly on 07/02/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor: UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double = 0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation: Double = 0.95 { didSet { updateLocations() }}
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) { didSet { updatePoints() }}
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0, y: 0) { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    private func updatePoints() {
//        if horizontalMode {
//            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
//            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
//        } else {
//            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
//            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
//        }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    private func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}
