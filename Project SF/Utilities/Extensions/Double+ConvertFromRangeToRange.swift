//
//  Double+ConvertFromRangeToRange.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import Foundation

extension Double {
    
    public func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
    
}
