//
//  File.swift
//  
//
//  Created by David Casserly on 08/04/2020.
//

import Foundation
import UIKit

public class BadgeLabel: UILabel {
        
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        textAlignment = .center
        //sizeToFit()
        let badgeSize = bounds.size
        
        let maxDimension = max(CGFloat(badgeSize.width), CGFloat(badgeSize.height))
        let height = maxDimension
        let width = maxDimension
        
        frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: height)
        
        layer.cornerRadius = bounds.size.height / 2
        
        if let text = self.text {
            isHidden = text != "" ? false : true
        } else {
            isHidden = true
        }
    }

}
