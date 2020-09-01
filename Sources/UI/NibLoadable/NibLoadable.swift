//
//  File.swift
//  
//
//  Created by David Casserly on 31/03/2020.
//

import Foundation
import UIKit

/*
 
    How to use (cos i always forget)
    ----------
 
    1. Create your view in a nib. Your custom view is Files owner NOT the top level view, which can just be a UIView.
    2. Make your custom view extend NibLoadableView
    3. Give your custom view this method:
 
        override var nibName: String {
            return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
        }
 
    4. You can now add your customer view into another nib. Add a UIView and set it's class to your new view class.
 
 */


/// Basically, you create a xib file with top level UIView and then add your elements to it. You can then use that type inside another xib or a storyboard
/// Be careful when 
public protocol NibLoadable {
    var nibName: String { get }
}

public extension NibLoadable where Self: UIView {

    var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    private static func nib(name: String) -> UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: name, bundle: bundle)
    }
    
    func setupFromNib() {
        guard let view = Self.nib(name: nibName).instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        self.backgroundColor = .clear
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}

/// You can either inherit from NibLoadableView or use NibLoadable protocol yourself
open class NibLoadableView: UIView, NibLoadable {
    
    open var nibName: String {
        preconditionFailure(
            """
                As you are using the NibLoadableView superclass, you must provide your own implementation of:

                    override var nibName: String {
                        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
                    }

                Alternatively, you would implement NibLoadable instead of extending NibLoadableView.
            """
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
}
