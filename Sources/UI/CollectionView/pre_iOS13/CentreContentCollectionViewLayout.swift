//
//  CentreContentCollectionViewLayout.swift
//
//  Created by David Casserly on 13/05/2018.
//  Copyright © 2018 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class CentreContentCollectionViewLayout: UICollectionViewFlowLayout {
        
    public override func prepare() {
        self.scrollDirection = .horizontal
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView, !collectionView.isPagingEnabled else {
            preconditionFailure("Can't use the layout without a collection view and isPaygingEnabled must be false")
        }
        
        let halfCollectionWidth: CGFloat = collectionView.bounds.size.width * CGFloat(0.50)
        let collectionViewCentre: CGFloat = proposedContentOffset.x + halfCollectionWidth
        
        let proposedRect: CGRect = collectionView.bounds
        let attributesArray = layoutAttributesForElements(in: proposedRect)!
        var candidateAttributes:UICollectionViewLayoutAttributes?
        
        for layoutAttributes : AnyObject in attributesArray {
            if let _layoutAttributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                if _layoutAttributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                    continue
                }
                if candidateAttributes == nil {
                    candidateAttributes = _layoutAttributes
                    continue
                }
                if fabsf(Float(_layoutAttributes.center.x) - Float(collectionViewCentre)) < fabsf(Float(candidateAttributes!.center.x) - Float(collectionViewCentre)) {
                    candidateAttributes = _layoutAttributes
                }
            }
        }
        
        if attributesArray.count == 0 {
            return CGPoint(x: proposedContentOffset.x - halfCollectionWidth * 2,y: proposedContentOffset.y)
        }
        
        return CGPoint(x: candidateAttributes!.center.x - halfCollectionWidth, y: proposedContentOffset.y)
    }
    
}
