//
//  NetworkManagerTests.swift
//  Project SFTests
//
//  Created by William Taylor on 10/7/20.
//

import XCTest
import Combine
@testable import Project_SF

class NetworkManagerTests: XCTestCase {
    
    // MARK: Network Manager
    
    func testNetworkManagerSuccessfulRequest() throws {
        let expect = XCTestExpectation()

        let mock = URLSessionMock()
        mock.data = Data([1, 0, 1, 1, 0])
        
        let networkManager = NetworkManager(urlSession: mock)

        networkManager.request(URL(string: "fake")) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, mock.data)
                expect.fulfill()
            default: return
            }
        }

        wait(for: [expect], timeout: 1)
    }
    
    func testNetworkManagerErrorRequest() throws {
        let expect = XCTestExpectation()
        
        let mock = URLSessionMock()
        mock.error = FakeError()
        
        let networkManager = NetworkManager(urlSession: mock)

        networkManager.request(URL(string: "fake")) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, NetworkManager.NetworkError.networkError)
                expect.fulfill()
            default: expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 1)
    }
    
    func testNetworkManagerNoDataRequest() throws {
        let expect = XCTestExpectation()

        let mock = URLSessionMock()
        
        let networkManager = NetworkManager(urlSession: mock)

        networkManager.request(URL(string: "fake")) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, NetworkManager.NetworkError.noDataInResponse)
                expect.fulfill()
            default: return
            }

        }

        wait(for: [expect], timeout: 1)
    }
    
    func testNetworkManagerRequestDecode() throws {
        let expect = XCTestExpectation()

        let mock = URLSessionMock()
        mock.data = """
        {
            "name": "test",
            "count": 10123
        }
        """.data(using: .utf8)
        
        let networkManager = NetworkManager(urlSession: mock)

        networkManager.request(URL(string: "fake"), decode: SampleData.self) { result in
            switch result {
            case .success(let decodedObject):
                XCTAssertEqual(decodedObject.name, "test")
                XCTAssertEqual(decodedObject.count, 10123)
                expect.fulfill()
            default: return
            }
        }

        wait(for: [expect], timeout: 1)
    }
    
    // MARK: Health Kit Controller
    
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
        
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
    }
    
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
        
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
    }
    
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
        
        func handle(expectedResult: Double, publisher: Published<Double>.Publisher) {
            let expectation = XCTestExpectation()
            let cancellable = publisher
                .filter {
                    return $0 == expectedResult
                }
                .sink { _ in
                    expectation.fulfill()
                }
            
            cancellables.append(cancellable)
            expectations.append(expectation)
        }
            
        handle(expectedResult: 100.0, publisher: controller.$moveCurrent)
        handle(expectedResult: 200.0, publisher: controller.$moveGoal)
        handle(expectedResult: 50, publisher: controller.$exerciseCurrent)
        handle(expectedResult: 60, publisher: controller.$exerciseGoal)
        handle(expectedResult: 50, publisher: controller.$standCurrent)
        handle(expectedResult: 60, publisher: controller.$standGoal)
        
        controller.updateAllActivityData()
        
        wait(for: expectations, timeout: 2)
        cancellables
            .forEach { $0.cancel() }
    }

}
