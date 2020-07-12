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

    // MARK: - Network Success Request
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

        wait(for: [expect], timeout: 5)
    }

    // MARK: - Network Error Request
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

        wait(for: [expect], timeout: 5)
    }

    // MARK: - Network No Data In Response
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

        wait(for: [expect], timeout: 5)
    }

    // MARK: - Network Request Decode
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

        wait(for: [expect], timeout: 5)
    }

}
