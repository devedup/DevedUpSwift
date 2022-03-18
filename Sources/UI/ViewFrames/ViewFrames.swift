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
        return self.superview?.convert(self.frame, to: rootView)
    }
}
