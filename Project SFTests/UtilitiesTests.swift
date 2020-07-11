//
//  UtilitiesTests.swift
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

import XCTest
import Foundation
@testable import Project_SF

class UtilitiesTests: XCTestCase {
    
    func testRangeConversion() throws {
        XCTAssertEqual(1.0.convert(fromRange: 0...10, toRange: 0...1), 0.1)
        XCTAssertEqual(0.25.convert(fromRange: 0...1, toRange: 0...100), 25.0)
        XCTAssertEqual(0.1.convert(fromRange: 0...1, toRange: 0...10), 1.0)
        XCTAssertEqual(0.convert(fromRange: 0...5, toRange: 0...10), 0)
        XCTAssertEqual(5.convert(fromRange: 0...5, toRange: 0...10), 10)
    }
    
}
