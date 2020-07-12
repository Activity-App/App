//
//  HealthKitControllerTests.swift
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

import XCTest
import Combine
@testable import Project_SF

class HealthKitControllerTests: XCTestCase {

    // MARK: - Test Auth Granted
    func testHealthKitControllerAuthorizationGranted() throws {
        let mock = HKHealthStoreMock()
        mock.authorizationResponse.error = nil
        mock.authorizationResponse.success = true
        
        let controller = HealthKitController(healthStore: mock)
        XCTAssert(controller.authorizationState == .notBegun)
        
        let expectation = XCTestExpectation()
        
        let cancellable = controller.$authorizationState
            .filter { $0 == .granted }
            .sink { _ in
                expectation.fulfill()
            }
        
        controller.authorizeHealthKit()
        
        wait(for: [expectation], timeout: 5)
        cancellable.cancel()
    }

    // MARK: - Test Auth Not Granted
    func testHealthKitControllerAuthorizationNotGranted() throws {
        let mock = HKHealthStoreMock()
        mock.authorizationResponse.success = false
        mock.authorizationResponse.error = FakeError()
        
        let controller = HealthKitController(healthStore: mock)
        XCTAssert(controller.authorizationState == .notBegun)
        
        let expectation = XCTestExpectation()
        
        let cancellable = controller.$authorizationState
            .filter { $0 == .notGranted }
            .sink { _ in
                expectation.fulfill()
            }
        
        controller.authorizeHealthKit()
        
        wait(for: [expectation], timeout: 5)
        cancellable.cancel()
    }

    // MARK: - Test Update Activity Data
    
    func testHealthKitControllerUpdateActivityData() throws {
        let mock = HKHealthStoreMock()
        let fakeResult = HKActivitySummaryMock()
        fakeResult.activeEnergyBurned = HKQuantity(unit: .largeCalorie(), doubleValue: 100.0)
        fakeResult.activeEnergyBurnedGoal = HKQuantity(unit: .largeCalorie(), doubleValue: 200.0)
        
        fakeResult.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 50.0)
        fakeResult.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 60.0)
        
        fakeResult.appleStandHours = HKQuantity(unit: .count(), doubleValue: 50.0)
        fakeResult.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 60.0)
        
        mock.activitySummaryQueryResponse.result = [fakeResult]
        
        let controller = HealthKitController(healthStore: mock)
        
        let expectation = XCTestExpectation()

        controller.updateTodaysActivityData {
            XCTAssertEqual(controller.latestActivityData.moveCurrent, 100, "Move value is not set correctly")
            XCTAssertEqual(controller.latestActivityData.moveGoal, 200, "Move goal is not set correctly")
            XCTAssertEqual(controller.latestActivityData.exerciseCurrent, 50, "Exercise value is not set correctly")
            XCTAssertEqual(controller.latestActivityData.exerciseGoal, 60, "Exercise goal is not set correctly")
            XCTAssertEqual(controller.latestActivityData.standCurrent, 50, "Stand value is not set correctly")
            XCTAssertEqual(controller.latestActivityData.standGoal, 60, "Stand goal is not set correctly")
            expectation.fulfill()
        }
        
        /*let currentValuesExpectation = XCTestExpectation()
        let currentValuesCancellable = controller.$moveCurrent.zip(controller.$exerciseCurrent, controller.$standCurrent)
            .sink { _ in
                guard controller.moveCurrent != 0, controller.exerciseCurrent != 0, controller.standCurrent != 0 else { return }
                XCTAssertEqual(controller.moveCurrent, 100, "Move value is not set correctly")
                XCTAssertEqual(controller.exerciseCurrent, 50, "Exercise value is not set correctly")
                XCTAssertEqual(controller.standCurrent, 50, "Stand value is not set correctly")
                
                currentValuesExpectation.fulfill()
            }*/
        
        wait(for: [expectation], timeout: 5)
    }

}
