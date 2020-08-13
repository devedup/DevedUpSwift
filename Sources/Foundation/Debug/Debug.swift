//
//  File.swift
//  
//
//  Created by David Casserly on 21/04/2020.
//

import Foundation

struct Debug {
    
    static func isDebugging() -> Bool {
        let dic = ProcessInfo.processInfo.environment
        if dic["xcodetesting"] == "true" {
            return true
        } else {
            return false
        }
    }
    
    static func isDebuggingNetwork() -> Bool {
        let dic = ProcessInfo.processInfo.environment
        if dic["networkdebugging"] == "true" {
            return true
        } else {
            return false
        }
    }
    
}
