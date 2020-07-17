//
//  Int+ConvertFromRangeToRange.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import Foundation

extension Int {
    
    public func convert(fromRange: (Int, Int), toRange: (Int, Int)) -> Int {
        var value = self
        value -= fromRange.0
        value /= Int(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
    
}
