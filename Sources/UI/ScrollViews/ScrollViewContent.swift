//
//  File.swift
//  
//
//  Created by David Casserly on 01/04/2020.
//

import Foundation
import UIKit

extension UIScrollView {
    
    public func addContentViewAndSetupConstraints(contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        let frameGuide = self.frameLayoutGuide
        let contentGuide = self.contentLayoutGuide
        NSLayoutConstraint.activate([
            //            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            //            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //            frameGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentGuide.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            contentGuide.heightAnchor.constraint(equalTo: frameGuide.heightAnchor)
        ])
    }
    
}
