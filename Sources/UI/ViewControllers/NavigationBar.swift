//
//  File.swift
//  
//
//  Created by David Casserly on 04/08/2020.
//

import Foundation
import UIKit

public extension UINavigationBar {
    
    func makeTransparent() {
        barStyle = .black
        setBackgroundImage(UIImage(), for: .default)
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        isTranslucent = true
        //setupBarTitleAttributes()
    }
    
}
