//
//  File.swift
//  
//
//  Created by David Casserly on 09/09/2020.
//

import Foundation
import UIKit

extension UISearchBar {
    public func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    public func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = textField.bounds.size.height / 2
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
}
