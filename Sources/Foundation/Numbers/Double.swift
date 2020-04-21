//
//  File.swift
//  
//
//  Created by David Casserly on 24/03/2020.
//

import Foundation

extension Double {
    public func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
