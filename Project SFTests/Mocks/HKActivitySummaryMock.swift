//
//  HKActivitySummaryMock.swift
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

import Foundation
import HealthKit

class HKActivitySummaryMock: HKActivitySummary {
    
    private static let hkQuantityZero = HKQuantity(unit: HKUnit.count(), doubleValue: 0)
    
    override var activeEnergyBurned: HKQuantity {
        get { _activeEnergyBurned }
        set { _activeEnergyBurned = newValue }
    }
    
    private var _activeEnergyBurned: HKQuantity = HKActivitySummaryMock.hkQuantityZero

    override var appleExerciseTime: HKQuantity {
        get { _appleExerciseTime }
        set { _appleExerciseTime = newValue }
    }
    
    private var _appleExerciseTime: HKQuantity = HKActivitySummaryMock.hkQuantityZero

    override var appleStandHours: HKQuantity {
        get { _appleStandHours }
        set { _appleStandHours = newValue }
    }
    
    private var _appleStandHours: HKQuantity = HKActivitySummaryMock.hkQuantityZero

    override var activeEnergyBurnedGoal: HKQuantity {
        get { _activeEnergyBurnedGoal }
        set { _activeEnergyBurnedGoal = newValue }
    }
    
    private var _activeEnergyBurnedGoal: HKQuantity = HKActivitySummaryMock.hkQuantityZero

    override var appleExerciseTimeGoal: HKQuantity {
        get { _appleExerciseTimeGoal }
        set { _appleExerciseTimeGoal = newValue }
    }
    
    private var _appleExerciseTimeGoal: HKQuantity = HKActivitySummaryMock.hkQuantityZero

    override var appleStandHoursGoal: HKQuantity {
        get { _appleStandHoursGoal }
        set {  _appleStandHoursGoal = newValue }
    }
    
    private var _appleStandHoursGoal: HKQuantity = HKActivitySummaryMock.hkQuantityZero
    
}
