//
//  File.swift
//  
//
//  Created by David Casserly on 15/02/2021.
//

import Foundation
import UIKit

open class UnderlinedButton: UIButton {
    
    @IBInspectable public var underlineColour: UIColor = UIColor.black {
        didSet {
            underline.backgroundColor = underlineColour
        }
    }
    
    private let underline = UIView()
    
// MARK: Init
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(underline)
        underline.isHidden = true
    }
    
    private var _isSelected: Bool = false
    public override var isSelected: Bool {
        didSet {
            _isSelected = isSelected
            underline.isHidden = !isSelected
        }
    }
    
// MARK: Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutSelectedUnderline()
    }
    
    private func layoutSelectedUnderline() {
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = 4.0
        let x: CGFloat = 0.0
        let y = self.bounds.size.height - height
        let frame = CGRect(x: x, y: y, width: width, height: height)
        underline.frame = frame
    }
    
}
