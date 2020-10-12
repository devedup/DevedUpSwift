//
//  File.swift
//  
//
//  Created by David Casserly on 14/09/2020.
//

import Foundation

public struct Stack<T> {
    
    public init() {
    }
    
    private var array: [T] = []
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
}
