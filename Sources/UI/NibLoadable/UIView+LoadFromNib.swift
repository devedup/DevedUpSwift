//
//  File.swift
//  
//
//  Created by David Casserly on 26/06/2021.
//

import Foundation
import UIKit

/*
 
 
    So I create a view and nib. The main view is the view i just created, the Files Owner is NibOwner.class (below)
 
 
    Nothing special in the view. Just ensure you connect your main view to Files Owner > NibOwner view outlet 
 
 
 class FeatureListItem: UIView {
     
     @IBOutlet var itemTitle: UILabel!
         
     public required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         sharedInit()
     }
     
     public override init(frame: CGRect) {
         super.init(frame: frame)
         sharedInit()
     }
     
     override func awakeFromNib() {
         super.awakeFromNib()
     }
     
     private func sharedInit() {
     }
     
 }
 
 
    I then loaded my view template into a stack view for example, like this:
 
 
 let items = presenter.subscriptionFeaturesForList
 let nib = FeatureListItem.nibFile()
 items.forEach { (item) in
     if let featureItem: FeatureListItem = nib.mainView() {
         featureItem.itemTitle.text = item.featureName
         featureItems.addArrangedSubview(featureItem)
     }
 }
 
 
 
 
 
 
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
    
    public class func nibFile() -> UINib {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: nil)
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



