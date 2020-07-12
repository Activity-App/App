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
    // swiftlint:disable function_body_length
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
        
        var cancellables = [AnyCancellable]()
        var expectations = [XCTestExpectation]()
        
        func handle(expectedResult: Double, publisher: Published<Double>.Publisher, description: String = "") {
            let expectation = XCTestExpectation(description: description)
            let cancellable = publisher
                .filter {
                    print(description, $0, expectedResult)
                    return $0 == expectedResult
                }
                .sink { _ in
                    expectation.fulfill()
                }
            
            cancellables.append(cancellable)
            expectations.append(expectation)
        }

        controller.updateTodaysActivityData {
            handle(expectedResult: 100.0,
                   publisher: controller.$moveCurrent,
                   description: "Move value is not set correctly")
            handle(expectedResult: 200.0,
                   publisher: controller.$moveGoal,
                   description: "Move goal is not set correctly")
            handle(expectedResult: 50.0,
                   publisher: controller.$exerciseCurrent,
                   description: "Exercise value is not set correctly")
            handle(expectedResult: 60.0,
                   publisher: controller.$exerciseGoal,
                   description: "Exercise goal is not set correctly")
            handle(expectedResult: 50.0,
                   publisher: controller.$standCurrent,
                   description: "Stand value is not set correctly")
            handle(expectedResult: 60.0,
                   publisher: controller.$standGoal,
                   description: "Stand goal is not set correctly")
        }
        
        wait(for: expectations, timeout: 5)
        cancellables
            .forEach { $0.cancel() }
    }

}
