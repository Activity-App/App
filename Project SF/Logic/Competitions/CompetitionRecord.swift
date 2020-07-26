//
//  CompetitionRecord.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import CloudKit

class CompetitionRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "Competitions"
    
    static let model = Model()

    let record: CKRecord

    // manually map from Int to ChallengeType
    var type: CompetitionTypes? {
        get {
            CompetitionTypes(
                move: self[dynamicMember: \.move] ?? true,
                exercise: self[dynamicMember: \.exercise] ?? true,
                stand: self[dynamicMember: \.stand] ?? true,
                steps: self[dynamicMember: \.steps] ?? false,
                distance: self[dynamicMember: \.distance] ?? false,
                stepsGoal: self[dynamicMember: \.stepsGoal] ?? 10000,
                distanceGoal: self[dynamicMember: \.distanceGoal] ?? 10
            )
        }
        set {
            self[dynamicMember: \.move] = newValue?.move
            self[dynamicMember: \.exercise] = newValue?.exercise
            self[dynamicMember: \.stand] = newValue?.stand
            self[dynamicMember: \.steps] = newValue?.steps
            self[dynamicMember: \.distance] = newValue?.distance
            self[dynamicMember: \.stepsGoal] = newValue?.stepsGoal
            self[dynamicMember: \.distanceGoal] = newValue?.distanceGoal
        }
    }
    
    // MARK: Model
    
    struct Model {
        
        let title = ModelItem<String>(key: "title")
        
        let move = ModelItem<Bool>(key: "move")
        let exercise = ModelItem<Bool>(key: "exercise")
        let stand = ModelItem<Bool>(key: "stand")
        let steps = ModelItem<Bool>(key: "steps")
        let distance = ModelItem<Bool>(key: "distance")
        let stepsGoal = ModelItem<Int>(key: "stepsGoal")
        let distanceGoal = ModelItem<Int>(key: "distanceGoal")
        
        let startDate = ModelItem<Date>(key: "startDate")
        let endDate = ModelItem<Date>(key: "endDate")
        let scoreURLHolderShareURLs = ModelItem<[String]>(key: "scoreURLHolderShareURLs")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: Competition Types
    
    struct CompetitionTypes {
        var move: Bool = true
        var exercise: Bool = true
        var stand: Bool = true
        var steps: Bool = false
        var distance: Bool = false
        var stepsGoal: Int = 10000
        var distanceGoal: Int = 10
    }
}
