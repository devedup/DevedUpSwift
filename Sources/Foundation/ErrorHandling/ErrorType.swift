//
//  File.swift
//  
//
//  Created by David Casserly on 23/08/2021.
//

import Foundation
import DevedUpSwiftLocalisation

public protocol ErrorType: Error {
    
    var title: String { get }
    var description: String { get }
    var underlyingError: Error? { get }
    var shouldDisplayToUser: Bool { get }
    
}

// Set some sensible defaults
public extension ErrorType {
    var title: String { "" }
    var underlyingError: Error? { self }
    var shouldDisplayToUser: Bool { true }
}
