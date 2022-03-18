//
//  LoadingLabel.swift
//
//  Created by David Casserly on 05/12/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class LoadingLabel: NibReplacableView {
    
    override var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            label.text = placeholder
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 12.0 {
        didSet {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    @IBInspectable var colour: UIColor = UIColor.black {
        didSet {
            label.textColor = colour
        }
    }
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var activity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //label.text = ""
        activity.startAnimating()
    }

    func showLoadingIndicator() {
        activity.startAnimating()
        label.isHidden = true
    }
    
    var text: String = "" {
        didSet {
            activity.stopAnimating()
            label.text = text
            label.isHidden = false
        }
    }
    
}
