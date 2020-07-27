//
//  User.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import CloudKit

/// A dynamic record of a user that will be stored in the associated users private db.
class UserRecord: DynamicRecord {
    
    // MARK: Properties
    
    /// The type of the record that will appear in CloudKit.
    static let type = "Users"
    
    static let model = Model()
    
    /// The user record represented as a CKRecord that can be saved/deleted/modified to/from CloudKit.
    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        let name = ModelItem<String>(key: "name")
        let username = ModelItem<String>(key: "username")
        let bio = ModelItem<String>(key: "bio")
        let profilePictureURL = ModelItem<String>(key: "profilePictureURL")
        let userInfoRecordName = ModelItem<String>(key: "userInfoRecordName")
        let friendShareURL = ModelItem<String>(key: "friendShareURL")
        let scoreRecordZoneName = ModelItem<String>(key: "scoreRecordZoneName")
        let scoreRecordRecordName = ModelItem<String>(key: "scoreRecordRecordName")
        let scoreRecordPublicShareURL = ModelItem<String>(key: "scoreRecordPublicShareURL")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
}
