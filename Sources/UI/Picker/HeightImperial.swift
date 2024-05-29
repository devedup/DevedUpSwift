// Created by David Casserly on 29/05/2024.
// Copyright (c) 2024 ___ORGANIZATIONNAME___. All rights reserved.

import Foundation

public struct HeightImperial: Equatable, Hashable {
    
    public let totalInches: Int
    
    public init?(totalInches: Int) {
        guard totalInches > 0 else {
            return nil
        }
        self.totalInches = totalInches
    }
    
    private let inchesInAFoot = 12
    
    public var inches: Int {
        return totalInches % inchesInAFoot
    }
    
    public var feet: Int {
        return (totalInches - inches) / inchesInAFoot
    }
    
    public var toString: String {
        return "\(feet)ft \(inches)in"
    }
}
