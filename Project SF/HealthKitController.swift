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
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleStandTime)!
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
}
