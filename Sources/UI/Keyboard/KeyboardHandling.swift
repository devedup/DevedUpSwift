//
//  File.swift
//  
//
//  Created by David Casserly on 28/03/2022.
//

import Foundation
import UIKit

/**
 
 Usage:

  Conform to it 
 extension AnyViewController: KeyboardHandler {}

 add outlet
 @IBOutlet var bottomConstraint: NSLayoutConstraint!
 
 Link to events
 override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         startObservingKeyboardChanges()
  }
     
  override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         stopObservingKeyboardChanges()
  }
 */

public protocol KeyboardHandling: AnyObject {
    var bottomConstraint: NSLayoutConstraint! { get set }
    
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
    func startObservingKeyboardChanges()
    func stopObservingKeyboardChanges()
}



extension KeyboardHandling where Self: UIViewController {
    
    public func startObservingKeyboardChanges() {
        // NotificationCenter observers
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        
        // Deal with rotations
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        
        // Deal with keyboard change (emoji, numerical, etc.)
        NotificationCenter.default.addObserver(forName: UITextInputMode.currentInputModeDidChangeNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillHide(notification)
        }
    }
    
    
    public func keyboardWillShow(_ notification: Notification) {
        let verticalPadding: CGFloat = 20 // Padding between the bottom of the view and the top of the keyboard
        
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = value.cgRectValue.height
        
        // Here you could have more complex rules, like checking if the textField currently selected is actually covered by the keyboard, but that's out of this scope.
        self.bottomConstraint.constant = keyboardHeight + verticalPadding
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    
    public func keyboardWillHide(_ notification: Notification) {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    public func stopObservingKeyboardChanges() {
        NotificationCenter.default.removeObserver(self)
    }
}
