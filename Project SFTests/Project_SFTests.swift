//
//  Project_SFTests.swift
//  Project SFTests
//
//  Created by William Taylor on 10/7/20.
//

import XCTest
@testable import Project_SF

class ProjectSFTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRangeConversion() throws {
        XCTAssertEqual(1.0.convert(fromRange: 0...10, toRange: 0...1), 0.1)
        XCTAssertEqual(0.25.convert(fromRange: 0...1, toRange: 0...100), 25.0)
        XCTAssertEqual(0.1.convert(fromRange: 0...1, toRange: 0...10), 1.0)
        XCTAssertEqual(0.convert(fromRange: 0...5, toRange: 0...10), 0)
        XCTAssertEqual(5.convert(fromRange: 0...5, toRange: 0...10), 10)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
