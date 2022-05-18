//
//  File.swift
//  
//
//  Created by David Casserly on 27/09/2020.
//

import Foundation
import UIKit

/*
 
    In the host view controller ensure you use this:
 
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.invalidateIntrinsicContentSize()
    }
 
 */
public class IntrinsicSizedCollectionView: UICollectionView {
    
    // This is exposed to allow the container that hosts the collection view to pass through a constraint for its' height
    // Then we autolayout runs it sets the height appropriately. I don't know why this just doesn't work on its own,
    // Maybe I overlooked something and this is superfluous.. but it's working
    public var containerHeightConstraint: NSLayoutConstraint?
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        // This is forcing the intrinsic content size to reset if there is a difference between it's own size
        // and what intrinsic size is reporting
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        // This passes up the new size to the container to allow it to resize itself
        // Not sure why this wouldn't work without this bit of code
        containerHeightConstraint?.constant = self.contentSize.height
        return self.contentSize
    }
    
}
