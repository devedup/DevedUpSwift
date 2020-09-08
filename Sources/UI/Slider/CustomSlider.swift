//
//  File.swift
//  
//
//  Created by David Casserly on 08/09/2020.
//

import Foundation
import UIKit

public class CustomSlider: UISlider {

     @IBInspectable public var trackHeight: CGFloat = 2

    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //set your bounds here
        return CGRect(x: 0, y: 0, width: bounds.width, height: trackHeight)
        //return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width - 40, height: trackHeight))
    }

}
