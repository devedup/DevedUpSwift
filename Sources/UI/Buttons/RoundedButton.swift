//
//  File.swift
//  
//
//  Created by David Casserly on 04/08/2020.
//

import Foundation
import UIKit

//@IBDesignable
open class RoundedButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    open override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    private func sharedInit() {
        cornerRadius = frame.size.height / 2
    }
    
}
