//
//  File.swift
//  
//
//  Created by David Casserly on 04/08/2020.
//

import Foundation
import UIKit

open class DUBaseViewController: UIViewController {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isInsideModalPresentation {
            if navigationController?.viewControllers.first == self {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "nav-close-icon")
                //navigationItem.leftBarButtonItem?.tintColor = .black
                //navigationItem.leftBarButtonItem?.action = #selector(navigateBack(_:))
            }
        }
    }
    
    @IBAction public func navigateBack(_ sender: Any) {
        if navigationController != nil {
            if navigationController?.visibleViewController == navigationController?.viewControllers.first {
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    public func createBackButton() {
        navigationItem.leftBarButtonItem?.image = UIImage(named: "nav-back-icon")
        //navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.action = #selector(navigateBack(_:))
    }
    
    
    
}
