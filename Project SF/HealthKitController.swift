//
//  HealthKitController.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import Foundation
import HealthKit

class HealthKitController: ObservableObject {
    
    let healthStore = HKHealthStore()
    @Published var processBegan = false
    @Published var success = false
    
    func authorizeHealthKit() {
        
        DispatchQueue.main.async {
            self.processBegan = true
        }
        
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes, completion: { success , _ in
            if success {
                print("Success! HK is working")
                DispatchQueue.main.async {
                    self.success = true
                }
            }
        })
    }
    
    func readHealthData() {
        let result: (HKActivitySummaryQuery, [HKActivitySummary]?, Error?) -> Void = { query, result, error in
            print(result![0])
        }
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let query = HKActivitySummaryQuery(predicate: devicePredicate, resultsHandler: result)
        healthStore.execute(query)
    }
}
