//
//  UICollectionViewLayouts.swift
//  ManchesterFC
//
//  Created by David Casserly on 25/11/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13, *)
final public class CollectionViewLayouts {
    
    public static func verticalScrollGrid2Wide(estimatedItemHeight: CGFloat, spacing: CGFloat = 30) -> UICollectionViewLayout {
        let itemHeight = NSCollectionLayoutDimension.estimated(estimatedItemHeight)
        
        // Item Size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: itemHeight)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group size
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: itemHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(spacing)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        //section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    public static func horizontalScrollGridOf4() -> UICollectionViewLayout {
        // Item Size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group size
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    public static func horizontalScrollFillScreen(didScrollToPoint: @escaping (CGPoint)->Void) -> UICollectionViewLayout {
        // Item Size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group size
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { (visibleItems, point, env) -> Void in
            didScrollToPoint(point)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}
