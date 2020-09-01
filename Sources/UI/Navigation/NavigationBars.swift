//
//  File.swift
//  
//
//  Created by David Casserly on 27/08/2020.
//

import Foundation
import UIKit

extension UINavigationItem {
    
    public func createActivtyRightBarButton(colour: UIColor) -> UIActivityIndicatorView {
        var activity: UIActivityIndicatorView!
        if #available(iOS 13, *)  {
            activity = UIActivityIndicatorView(style: .medium)
        } else {
            activity = UIActivityIndicatorView(style: .gray)
        }
        activity.hidesWhenStopped = true
        activity.color = colour
        let activityBarButton = UIBarButtonItem(customView: activity)
        rightBarButtonItem = activityBarButton
        return activity
    }
    
}
