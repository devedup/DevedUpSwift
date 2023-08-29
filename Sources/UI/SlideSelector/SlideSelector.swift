//  SlideSelector.swift
//
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//
import UIKit

public enum SlideSelectorStyle {
    case roundedButtons
    case underline
}


public typealias SelectionChangeHandler = (_ sliderText: String, _ position: Int) -> Void
public typealias SelectionShouldChangeHandler = (_ sliderText: String, _ position: Int) -> Bool
    
public final class SlideSelectorView: UIView {
    
    public var sliderColor = UIColor.green
    public var sliderFont = UIFont.systemFont(ofSize: 10)
    public var sliderTextColor = UIColor.clear
    public var sliderBackgroundColour = UIColor.yellow
    public var otherTextColor = UIColor.clear
    public var sliderBorderColour = UIColor.black
    public var sliderBorderColourSelected = UIColor.red
    public var lowerLineColour = UIColor.red
    
    public var selectionShouldChange: SelectionShouldChangeHandler?
    public var selectionDidChange: SelectionChangeHandler?
    
    public var components: [String] = [] {
        didSet {
            componentLabels.forEach {
                $0.removeFromSuperview()
            }
            componentLabels.removeAll()
            components.forEach {
                let componentLabel = UILabel(frame: CGRect.zero)
                componentLabel.backgroundColor = UIColor.clear
                componentLabel.textAlignment = .center
                componentLabel.text = $0
                componentLabel.font = sliderFont
                componentLabel.textColor = otherTextColor
                componentLabel.layer.zPosition = 0.0
                componentLabels.append(componentLabel)
                addSubview(componentLabel)
            }
            setNeedsLayout()
        }
    }
    
    private var isPanning = false
    private var componentLabels = [UILabel]()
    private var slider: SliderButton2?
    public var sliderPosition: Int = 0 {
        didSet {
            if oldValue != sliderPosition {
                selectionDidChange?((components)[self.sliderPosition], sliderPosition)
                setSlideTextForCurrentPosition()
            }
        }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
    }

    // MARK: - Public methods
    
    public func setSliderPosition(_ position: Int, animated: Bool, notifyListeners notify: Bool = false) {
        assert(position > -1 && position < componentLabels.count, "Invalid slider position")
        if notify {
            sliderPosition = position
        } else {
            sliderPosition = position
        }
        let nextCenter: CGPoint = centerPositionForSlider(atPosition: position)
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.slider?.center = nextCenter
            }, completion: { (success) in
                
            })
        } else {
            slider?.center = nextCenter
        }
    }
    
    // MARK: - On Selection Change
    
    private func setSlideTextForCurrentPosition() {
        guard let slider = slider else {
            return
        }
        let currentCenter = slider.center
        let halfSliderWidth = slider.bounds.size.width / 2
        let minBounds = currentCenter.x - halfSliderWidth
        let maxBounds = currentCenter.x + halfSliderWidth
        //loop around the centers, finding the closest
        var nextPosition: Int = 0
        while true {
            if nextPosition >= (components).count {
                //done = YES;
                break
            }
            let nextCenter: CGPoint = centerPositionForSlider(atPosition: nextPosition)
            if nextCenter.x > minBounds && nextCenter.x < maxBounds {
                for label: UILabel in componentLabels {
                    label.textColor = otherTextColor
                }
                let newLabel = componentLabels[nextPosition]
                newLabel.textColor = sliderTextColor
                break
            }
            nextPosition += 1
        }
    }
    
    // MARK: - Layout
    
    private func createSlider() {
        if slider == nil {
            let slider = SliderButton2(frame: CGRect.zero, sliderColor: sliderColor, sliderBorderColor: sliderBorderColourSelected)
            addSubview(slider)
            self.slider = slider
            _ = GestureFactory.addPan(to: slider, target: self, action: #selector(SlideSelectorView.handlePan(_:)))
            _ = GestureFactory.addSingleTap(to: self, target: self, action: #selector(SlideSelectorView.singleTapped(_:)))
        }
    }
        
    public override func layoutSubviews() {
        // Create slider
        createSlider()

        let sliderWidth = bounds.size.width / CGFloat(components.count)
        let sliderHeight = bounds.size.height
        
        //Slider Size
        slider?.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight)
        slider?.center = centerPositionForSlider(atPosition: sliderPosition)
        //now the background labels
        var position: Int = 0
        for label: UILabel in componentLabels {
            label.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight)
            label.center = centerPositionForSlider(atPosition: position)
            position += 1
        }
        if let slider = slider {
            bringSubviewToFront(slider)
        }
        setSlideTextForCurrentPosition()
    }
    
    func centerPositionForSlider(atPosition position: Int) -> CGPoint {
        guard let slider = slider else {
            return CGPoint(x: 0, y: 0)
        }
        assert(position > -1 && position < components.count, "Invalid slider position")
        let width = bounds.size.width
        let sliderWidth = width / CGFloat(components.count)
        let sliderX = ((sliderWidth * CGFloat(position)) + sliderWidth) - (sliderWidth / 2)
        return CGPoint(x: sliderX, y: slider.center.y )
    }
    
    func snapIntoPosition() {
        guard let slider = slider else {
            return
        }
        
        // If they have implemented selectionShouldChange, otherwise it's true
        if let canChange = selectionShouldChange?((components)[self.sliderPosition], sliderPosition) {
            if canChange == false {
                // Reset, snap back
                let nextCenter: CGPoint = centerPositionForSlider(atPosition: self.sliderPosition)
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    slider.center = nextCenter
                }, completion: nil)
                return
            }
        }
        
        let currentCenter = slider.center
        let halfSliderWidth = slider.bounds.size.width / 2
        let minBounds = currentCenter.x - halfSliderWidth
        let maxBounds = currentCenter.x + halfSliderWidth
        //loop around the centers, finding the closest
        var nextPosition: Int = 0
        while true {
            let nextCenter: CGPoint = centerPositionForSlider(atPosition: nextPosition)
            if nextCenter.x > minBounds && nextCenter.x < maxBounds {
                //snapped = YES;
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    slider.center = nextCenter
                }, completion: { finished in
                    self.sliderPosition = nextPosition
                })
                break
            }
            nextPosition += 1
        }
    }
    
    // MARK: - Drawing the component
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        // Rectangle Drawing
        sliderBackgroundColour.setFill()
        sliderBorderColour.setStroke()
        let borderWidth: CGFloat = 2.0
        let height = bounds.size.height
        let bodyRect = CGRect(x: 1, y: 1, width: bounds.size.width - borderWidth, height: height - borderWidth)
        let bodyPath = UIBezierPath(roundedRect: bodyRect, cornerRadius: height / 2)
        context?.addPath(bodyPath.cgPath)
        context?.setLineWidth(2)
        context?.drawPath(using: .fillStroke)
        
        // Draw line along bottom
        lowerLineColour.setFill()
        lowerLineColour.setStroke()
        let horizontalPadding: CGFloat = 1
        let verticalPadding: CGFloat = 1
        let lineWidth: CGFloat = bounds.size.width - (2 * horizontalPadding)
        let lineHeight: CGFloat = 2
        let xPosition: CGFloat = horizontalPadding
        let yPosition: CGFloat = bounds.size.height - verticalPadding - lineHeight
        let lineRect = CGRect(x: xPosition, y: yPosition , width: lineWidth, height: lineHeight)
        let linePath = UIBezierPath(roundedRect: lineRect, cornerRadius: lineHeight/2)
        context?.addPath(linePath.cgPath)
        context?.setLineWidth(lineHeight)
        context?.drawPath(using: .fillStroke)
    }
    
    public override func draw(_ rect: CGRect) {
        drawBackground()
    }
    
}

extension SlideSelectorView: UIGestureRecognizerDelegate {
    
    // MARK: - Gestures
    
    @objc func singleTapped(_ tapGesture: UITapGestureRecognizer) {
        guard let slider = slider else {
            return
        }
        
        // If they have implemented selectionShouldChange, otherwise it's true
        if let canChange = selectionShouldChange?((components)[self.sliderPosition], sliderPosition) {
            if !canChange {
                return
            }
        }
        
        let tapLocation = tapGesture.location(in: self)
        let sliderWidth = slider.bounds.size.width
        var nextMaxX = Int(sliderWidth)
        var nextPosition = 0
        while true {
            if tapLocation.x < CGFloat(nextMaxX) {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    slider.center = self.centerPositionForSlider(atPosition: nextPosition)
                }, completion: { finished in
                    self.sliderPosition = nextPosition
                })
                break
            }
            nextMaxX += Int(sliderWidth)
            nextPosition += 1
        }
    }
    
    @objc func handlePan(_ panGesture: UIPanGestureRecognizer) {
        guard let slider = panGesture.view else {
            return
        }
        
        switch panGesture.state {
        case .began:
            isPanning = true
        case .changed:
            if isPanning {
                let translation = panGesture.translation(in: slider)
                let minCenter = centerPositionForSlider(atPosition: 0)
                let maxCenter = centerPositionForSlider(atPosition: components.count - 1)
                let newCenterX = slider.center.x + translation.x
                let newCenter = CGPoint(x: newCenterX, y: slider.center.y)
                if newCenter.x > minCenter.x && newCenter.x < maxCenter.x {
                    slider.center = newCenter
                    setSlideTextForCurrentPosition()
                }
                panGesture.setTranslation(CGPoint.zero, in: slider)
            }
        case .ended:
            isPanning = false
            snapIntoPosition()
        default:
            break
        }
    }
    
}

private class SliderButton: UIView {
    
//    var leftColour: UIColor = ColourNames.gradientLeft.colour
//    var rightColour: UIColor = ColourNames.gradientRight.colour
    
    private let sliderColor: UIColor
    private let sliderBorderColour: UIColor

    // MARK: - Init
    
    init(frame: CGRect, sliderColor: UIColor, sliderBorderColor: UIColor) {
        self.sliderBorderColour = sliderBorderColor
        self.sliderColor = sliderColor
        
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = UIColor.clear
        autoresizingMask = .flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }
    
    // MARK: - Drawing & Layout
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let width = bounds.size.width - 2
        let height = bounds.size.height - 2
        sliderColor.setFill()
        sliderBorderColour.setStroke()
        let bodyRect = CGRect(x: 1, y: 1, width: width, height: height)
        let bodyPath = UIBezierPath(roundedRect: bodyRect, cornerRadius: height/2)
        context?.addPath(bodyPath.cgPath)
        context?.setLineWidth(2)
        context?.drawPath(using: .fillStroke)
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        gradientLayer.frame = bounds
//    }

//    public lazy var gradientLayer: CAGradientLayer = {
//        let l = CAGradientLayer()
//        l.frame = self.bounds
//        l.colors = [leftColour.cgColor, rightColour.cgColor]
//        l.startPoint = CGPoint(x: 0, y: 0.5)
//        l.endPoint = CGPoint(x: 1, y: 0.5)
//        l.cornerRadius = self.bounds.height / 2
//        layer.insertSublayer(l, at: 0)
//        return l
//    }()
    
}

private class SliderButton2: UIView {
    
    private let sliderColor: UIColor
    private let sliderBorderColour: UIColor

    // MARK: - Init
    
    init(frame: CGRect, sliderColor: UIColor, sliderBorderColor: UIColor) {
        self.sliderBorderColour = sliderBorderColor
        self.sliderColor = sliderColor
        
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = UIColor.clear
        autoresizingMask = .flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }
    
    // MARK: - Drawing & Layout
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let width = bounds.size.width - 2
        let height: CGFloat = 2
        sliderColor.setFill()
        sliderBorderColour.setStroke()
        let verticalPadding: CGFloat = 1
        let xPosition: CGFloat = verticalPadding
        let yPosition: CGFloat = bounds.size.height - verticalPadding - height
        let bodyRect = CGRect(x: xPosition, y: yPosition , width: width, height: height)
        let bodyPath = UIBezierPath(roundedRect: bodyRect, cornerRadius: height/2)
        context?.addPath(bodyPath.cgPath)
        context?.setLineWidth(2)
        context?.drawPath(using: .fillStroke)
    }
    
}
