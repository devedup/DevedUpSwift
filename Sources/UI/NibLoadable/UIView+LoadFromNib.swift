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



