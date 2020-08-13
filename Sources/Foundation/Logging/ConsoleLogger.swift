//
//  File.swift
//  
//
//  Created by David Casserly on 04/08/2020.
//

import Foundation

public struct ConsoleLogger: TextOutputStream, Loggable {

    public init() {
    }
    
    public func write(_ string: String) {
        if Debug.isDebuggingNetwork() {
            print(string)
        }
    }
    
}
