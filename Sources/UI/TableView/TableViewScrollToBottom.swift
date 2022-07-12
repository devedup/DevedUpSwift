//
//  File.swift
//  
//
//  Created by David Casserly on 12/07/2022.
//

import Foundation
import UIKit

extension UITableView {
    
    public func scrollToBottom(animated: Bool) {
        guard numberOfSections > 0 else { return }
        guard dataSource != nil else { return }
        
        let lastSection = numberOfSections - 1
        let lastItemIndex = dataSource?.tableView(self, numberOfRowsInSection: lastSection)
        
        guard let lastItemIndex = lastItemIndex, lastItemIndex >= 1 else { return }
        let indexToScrollTo = lastItemIndex - 1
        
        let indexPath = IndexPath(row: indexToScrollTo, section: lastSection)
        scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
}
