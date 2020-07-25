//
//  UserActivityRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

class UserActivityRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "UserActivity"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        let move = ModelItem<Int>(key: "move")
        let exercise = ModelItem<Int>(key: "exercise")
        let stand = ModelItem<Int>(key: "stand")
        let steps = ModelItem<Int>(key: "steps")
        let distance = ModelItem<Int>(key: "distance")
        
        let moveGoal = ModelItem<Int>(key: "moveGoal")
        let exerciseGoal = ModelItem<Int>(key: "exerciseGoal")
        let standGoal = ModelItem<Int>(key: "standGoal")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}

