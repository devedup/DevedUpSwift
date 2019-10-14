//  ClosureWrapper.swift
//  JDP
//
//  Created by App Sauce Ltd.
//  Copyright © 2019 JDP. All rights reserved.
//

import Foundation

@objc class ClosureWrapper: NSObject {
    
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
        super.init()
    }
    
    @objc func invoke () {
        closure()
    }
    
}
