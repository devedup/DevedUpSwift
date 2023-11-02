//
//  File.swift
//  
//
//  Created by David Casserly on 31/03/2020.
//

import Foundation
import UIKit

/* THERE ARE THREE WAYS YOU CAN DO THIS */
/* ------------------------------------ */

/*
    
    OPTION 1
    --------
 
    If you want to place a view placeholder in a storyboard and have it automatically replaced by a view
    from a xib file. Then follow these steps.
 
 
    How to use (cos i always forget)
    ----------
 
    1. Create your view in a nib file and create your view swift class that extends NibReplacableView
        Set FilesOwner to your custom swift view file
        The top level view can just be a UIView NOT your custom view
        Wire up your outlets to FilesOwner
    2. Make your custom view extend NibReplacableView
    3. Give your custom view this method:
 
        override var nibName: String {
            return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
        }
 
    4. You can now add a UIView to any other storyboard and set it's class to the name of your new view class and it will inject it automatically at runtime. (It adds it as a subview to the placeholder view you just put here)
 
 */


/// Basically, you create a xib file with top level UIView and then add your elements to it. You can then use that type inside another xib or a storyboard
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
    
    func setupFromNib(){
        guard let view = Self.nib(name: nibName).instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }
                
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
// Extending NibReplacableView means that you don't have to add these methods with setupFromNib()
open class NibReplacableView: UIView, NibLoadable {
    
    public var hasBeenSetup = false
        
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

/*
    
    OPTION 2
    --------
 
    If you want to load a view once in code. Your nib owner can be empty and your top level view is your custom
    view class.
 
    Then you can load it with simply this:
 
    let healthView: HealthView = HealthView.loadFromNib()
 
 */

extension UIView
{
    public class func loadFromNib<T: UIView>() -> T
    {
        guard let view = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?[0] as? T else {
            preconditionFailure("Unable to load nib named \(String(describing: T.self))")
        }
        
        return view
    }
    
}

/*
    
    OPTION 3
    --------
 
    Now i think option 2 and 3 could be refactored into one type.. but i'm tired
 
    There is ANOTHER STEP to remember here.
    Your nib owner is NibOwner and  you have to connect the View to the owner
    Your top level view is your custom view class as in Option 2.
    
 
    If you are loading lots of views, you might want to cache the UINib file first
    
  
    let nib = ProfileViewQuestion.nibFile()
    if let promptView: ProfileViewQuestion = nib.mainView() {
 
    }
 
 */

extension UIView
{
    public class func nibFile(bundle: Bundle? = nil) -> UINib {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib
    }
    
}

extension UINib {

    public func mainView<T: UIView>() -> T? {
        let nibOwner = NibOwner()
        instantiate(withOwner: nibOwner, options: nil)
        return nibOwner.view as? T
    }

}

/// This is your files owner for your custom nib
public class NibOwner: NSObject {
    @IBOutlet var view: UIView!
}

