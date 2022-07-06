//
//  CopyableTextLabel.swift
//  Fitafy
//
//  Created by David Casserly on 01/07/2022.
//  Copyright © 2022 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class CopyableTextLabel: UILabel {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    open override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    public func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
    
    public override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.hideMenu()
    }
    
    @objc private func showMenu() {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        guard !menu.isMenuVisible else {
            return
        }
        menu.showMenu(from: self, rect: self.bounds)
    }
    
}
