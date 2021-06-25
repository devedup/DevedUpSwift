//  Style.swift
//  SimbaSleep
//
//  Copyright © 2018 SimbaSleep. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class TouchDownGestureRecogniser: UIGestureRecognizer {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = UIGestureRecognizer.State.recognized
    }
    
}
