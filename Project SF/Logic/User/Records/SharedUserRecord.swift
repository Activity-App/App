//
//  SharedDataRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

/// A dynamic record for getting or setting all data that should be shared with a users friends. This should only be saved in the private db and shared through a CKShare and participants shared database.
class SharedUserRecord: DynamicRecord {
    
    // MARK: Properties
    
    /// The type of the record that will appear in CloudKit.
    static let type = "SharedUser"
    
    static let model = Model()

    /// The user info record represented as a CKRecord that can be saved/deleted/modified to/from CloudKit.
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
        
        let name = ModelItem<String>(key: "name")
        let username = ModelItem<String>(key: "username")
        let bio = ModelItem<String>(key: "bio")
        let profilePictureURL = ModelItem<String>(key: "profilePictureURL")
        let privateUserRecordName = ModelItem<String>(key: "privateUserRecordName")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
}
