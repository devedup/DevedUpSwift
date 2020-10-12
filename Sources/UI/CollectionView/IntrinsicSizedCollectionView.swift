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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
    
}