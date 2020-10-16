//
//  File.swift
//  
//
//  Created by David Casserly on 14/10/2020.
//

import Foundation
import UIKit

/// Note that your cells need the hugging and compresion resistant priorities set to 1000 to the content view
/// You also need a containerHeightConstraint set on the container view that you pass into this in the segue setup
open class StackEmbededCollectionViewController: UIViewController {
    
    @IBOutlet public var collectionView: IntrinsicSizedCollectionView!
    
    public var containerHeightConstraint: NSLayoutConstraint?
    
    open var collectionViewLayout: UICollectionViewLayout {
        preconditionFailure("You need to overide collectionViewLayout")
        // return CollectionViewLayouts.verticalScrollGrid2Wide(estimatedItemHeight: CGFloat(itemHeight))
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // This allows this view to expand the container it is inside in the stackview
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = collectionViewLayout
        
        guard containerHeightConstraint != nil else {
            preconditionFailure("You need to inject the containerHeightConstraint")
        }
        guard collectionView != nil else {
            preconditionFailure("You need to set the collectionView from storyboard")
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Annoyinng that I have to do this. Autolayout and IntrinsicSizedCollectionView should do it.
        containerHeightConstraint?.constant = collectionView.contentSize.height
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.invalidateIntrinsicContentSize()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
