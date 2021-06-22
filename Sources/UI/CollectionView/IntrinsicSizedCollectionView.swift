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
    
    public var containerHeightConstraint: NSLayoutConstraint?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
//        print("Laying out IntrinsicSizedCollectionView")
//        print("Bounds size \(bounds.size)")
//        print("Intrinsic size \(intrinsicContentSize)")
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
//
//        if bounds.size != intrinsicContentSize {
//            invalidateIntrinsicContentSize()
//        }
    }
    
    public override var intrinsicContentSize: CGSize {
//        print("Container Height Constraint \(containerHeightConstraint?.constant)")
//        print("Content Size \(self.contentSize.height)")
        containerHeightConstraint?.constant = self.contentSize.height
        return self.contentSize
    }
    
}
