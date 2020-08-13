//
//  File.swift
//  
//
//  Created by David Casserly on 12/08/2020.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
