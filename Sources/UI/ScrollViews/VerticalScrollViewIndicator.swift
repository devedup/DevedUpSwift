//
//  File.swift
//  
//
//  Created by David Casserly on 09/06/2021.
//

import Foundation
import UIKit

public class CustomScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    private var slider = VerticalScrollViewIndicator()
    private var sliderYPosition: NSLayoutConstraint?
    private var indicatorYPadding: CGFloat = 5
    private var indicatorXPadding: CGFloat = -4
    
    @IBInspectable
    public var sliderColour: UIColor = UIColor.white {
        didSet {
            slider.sliderColour = sliderColour
            slider.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var sliderBackgroundColour: UIColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            slider.sliderBackgroundColour = sliderBackgroundColour
            slider.setNeedsDisplay()
        }
    }
    
    // MARK: - initializers
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset")
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        addSubview(slider)
        slider.sliderColour = sliderColour
        slider.sliderBackgroundColour = sliderBackgroundColour
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.layer.zPosition = 10
        slider.widthAnchor.constraint(equalToConstant: 5).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 100).isActive = true
        slider.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor, constant: indicatorXPadding).isActive = true
        sliderYPosition = slider.topAnchor.constraint(equalTo: frameLayoutGuide.topAnchor, constant: indicatorYPadding)
        sliderYPosition?.isActive = true
        observerScrolling()
    }
    
    private func observerScrolling() {
        addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? CustomScrollView {
            if keyPath == "contentOffset" {
                slider.scrollViewDidScroll(obj)
                let yOffset = contentOffset.y
                sliderYPosition?.constant = -min(yOffset, 0) + indicatorYPadding
            }
        }
    }
    
}

private class VerticalScrollViewIndicator: UIView {
    
    // You can do it this way... or...
    public var sliderPercentage: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // you can do it this way....
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height - scrollView.bounds.size.height
        let verticalOffset = scrollView.contentOffset.y
        let percentYScrolled = verticalOffset / contentHeight
        sliderPercentage = percentYScrolled
    }
    
    var sliderColour: UIColor = UIColor.white
    var sliderBackgroundColour: UIColor = UIColor.white
    
    // MARK: - initializers

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBackground()
        drawSlider()
    }
    
    func drawSlider() {
        // Y position will go from 0 -> (totalHeight minus sliderHeight)
        // So if total is 200.... , slider is 50, total is 0 -> 150
        // So multiple 150 by percentage to get the Y position
        let sliderHeight = bounds.size.height / 4
        let width = bounds.size.width
        let maxYOffset = bounds.size.height - sliderHeight
        let scrollOffset = maxYOffset * max(min(sliderPercentage, 1), 0) // i.e between 0 and 1
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: scrollOffset, width: width, height: sliderHeight), cornerRadius: width/2)
        sliderColour.setFill()
        rectanglePath.fill()
    }
    
    func drawBackground() {
        let height = bounds.size.height
        let width = bounds.size.width
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: width/2)
        sliderBackgroundColour.setFill()
        rectanglePath.fill()
    }
    
}
