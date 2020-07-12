//
//  HealthKitController.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import Foundation
import HealthKit

class HealthKitController: ObservableObject {
    
    // MARK: Properties

    let healthStore: HKHealthStore
    
    // MARK: Published Properties

    @Published var authorizationState = AuthorizationState.notBegun
    
    @Published var moveCurrent = 0.0
    @Published var moveGoal = 1.0

    @Published var exerciseCurrent = 0.0
    @Published var exerciseGoal = 30.0

    @Published var standCurrent = 0.0
    @Published var standGoal = 12.0
    
    // MARK: Init
    
    init(healthStore: HKHealthStore = .init()) {
        self.healthStore = healthStore
    }
    
    // MARK: Methods

    // MARK: - Auth health kit
    
    /// Authorize HealthKit with specified types. Will present a screen to give access if not previously enabled.
    func authorizeHealthKit() {
        DispatchQueue.main.async {
            self.authorizationState = .processStarted
        }

        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.activitySummaryType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes, completion: { success, _ in
            DispatchQueue.main.async {
                if success {
                    print("Success! HK is working")
                    self.authorizationState = .granted
                } else {
                    self.authorizationState = .notGranted
                }
            }
        })
    }

    // MARK: - Get activity data
    
    /// Gets activity data for specified date with completion containing result.
    /// - Parameters:
    ///   - date: Date to fetch activity data
    ///   - completion: Completion that returns move, exercise, stand, error in that order.
    func getActivityData(for date: Date,
                         completion: @escaping (ActivityResult?, ActivityResult?, ActivityResult?, Error?) -> Void) {
        
        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: date)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: date, options: .strictStartDate)
        let query = HKActivitySummaryQuery(predicate: predicate) { _, result, error in
            guard let result = result?.last else {
                if let error = error {
                    print(error)
                    completion(nil, nil, nil, error)
                }
                return
            }
            
            let moveUnits = HKUnit.largeCalorie()
            let exerciseUnits = HKUnit.minute()
            let standUnits = HKUnit.count()
            
            let moveResult = ActivityResult(
                type: .move,
                current: result.activeEnergyBurned.doubleValue(for: moveUnits),
                goal: result.activeEnergyBurnedGoal.doubleValue(for: moveUnits)
            )
            let exerciseResult = ActivityResult(
                type: .exercise,
                current: result.appleExerciseTime.doubleValue(for: exerciseUnits),
                goal: result.appleExerciseTimeGoal.doubleValue(for: exerciseUnits)
            )
            let standResult = ActivityResult(
                type: .exercise,
                current: result.appleStandHours.doubleValue(for: standUnits),
                goal: result.appleStandHoursGoal.doubleValue(for: standUnits)
            )
            
            completion(moveResult, exerciseResult, standResult, nil)
        }
        healthStore.execute(query)
    }

    // MARK: - Get health data
    
    /// Gets health data for specified date with completion containing result.
    /// Remember to include requested data types in auth first!
    /// - Parameters:
    ///   - data: HealthKit quantity type for data
    ///   - unit: HealthKit unit type for data
    ///   - date: Date to fetch health data
    ///   - completion: Completion that returns result as double as well as error if that occured.
    func getHealthData(data: HKQuantityTypeIdentifier,
                       unit: HKUnit, for date: Date,
                       completion: @escaping (Double?, Error?) -> Void) {
        let dataType = HKQuantityType.quantityType(forIdentifier: data)

        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: date)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: date, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: dataType!,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum],
            anchorDate: startOfDay as Date,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else {
                if let error = error {
                    print(error)
                    completion(nil, error)
                }
                return
            }
            
            result.enumerateStatistics(from: startOfDay, to: date) { statistics, _ in
                if let quantity = statistics.sumQuantity()?.doubleValue(for: unit) {
                    completion(quantity, nil)
                }
            }
        }
    }

    // MARK: - Update todays activity
    
    /// Update this classes activity values with the latest activity values from HealthKit
    /// - Parameter completion: Gets called when the activity data is updated.
    func updateTodaysActivityData(_ completion: @escaping () -> Void = {}) {
        getActivityData(for: Date()) { move, exercise, stand, error in
            if error != nil {
                print(error!)
                return
            } else {
                DispatchQueue.main.async {
                    self.moveCurrent = move!.current
                    self.moveGoal = move!.goal
                    
                    self.exerciseCurrent = exercise!.current
                    self.exerciseGoal = exercise!.current
                    
                    self.standCurrent = stand!.current
                    self.standGoal = stand!.current

                    completion()
                }
            }
        }
    }
    
    // MARK: Authorization State
    
    enum AuthorizationState {
        case notBegun
        case processStarted
        case granted
        case notGranted
    }
}
