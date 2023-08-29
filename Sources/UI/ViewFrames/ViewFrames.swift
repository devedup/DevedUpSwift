//
//  File.swift
//  
//
//  Created by David Casserly on 17/03/2022.
//

import Foundation
import UIKit

extension UIView {
    public var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        let rect = self.superview?.convert(self.frame, to: rootView)
        return rect
    }
}
