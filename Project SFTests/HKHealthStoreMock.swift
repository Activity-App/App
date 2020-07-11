//
//  HKHealthStoreMock.swift
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

import Foundation
import HealthKit

class HKHealthStoreMock: HKHealthStore {
    
    // MARK: Properties
    
    var authorizationResponse = AuthorizationResponse(success: true, error: nil)
    
    var activitySummaryQueryResponse = ActivitySummaryQueryResponse(result: nil, error: nil)
    
    // MARK: Overriden Methods
    
    override func requestAuthorization(toShare typesToShare: Set<HKSampleType>?,
                                       read typesToRead: Set<HKObjectType>?,
                                       completion: @escaping (Bool, Error?) -> Void) {
        completion(authorizationResponse.success, authorizationResponse.error)
    }
    
    override func execute(_ query: HKQuery) {
        if let query = query as? HKActivitySummaryQuery {
            let resultsHandler = query.getResultsHandler()!
            resultsHandler(query,
                           activitySummaryQueryResponse.result,
                           activitySummaryQueryResponse.error)
        } else {
            fatalError("Mock doesn't support this type of query yet")
        }
    }
    
    // MARK: - Authorization Response
    
    struct AuthorizationResponse {
        
        var success: Bool
        
        var error: Error?
        
    }
    
    // MARK: - Activity Summary Query Response
    
    struct ActivitySummaryQueryResponse {
        
        var result: [HKActivitySummary]?
        
        var error: Error?
        
    }
}
