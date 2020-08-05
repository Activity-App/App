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
        
        let publicUserRecordName = ModelItem<String>(key: "publicUserRecordName")
        let sharedUserRecordName = ModelItem<String>(key: "sharedUserRecordName")
        
        let friendShareURLs = ModelItem<[String]>(key: "friendShareURLs")
        let friendShareURL = ModelItem<String>(key: "friendShareURL")
        
        let scoreRecordZoneName = ModelItem<String>(key: "scoreRecordZoneName")
        let scoreRecordRecordName = ModelItem<String>(key: "scoreRecordRecordName")
        let scoreRecordPublicShareURL = ModelItem<String>(key: "scoreRecordPublicShareURL")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    convenience init(recordName: String, user: User) {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: UserRecord.type, recordID: recordID)
        self.init(record: record)
        
        self.name = user.name
        self.username = user.username
        self.bio = user.bio
        self.profilePictureURL = user.profilePictureURL
        self.publicUserRecordName = user.publicUserRecordName
        self.sharedUserRecordName = user.sharedUserRecordName
        self.friendShareURLs = user.friendShareURLs
        self.friendShareURL = user.friendShareURL
        self.scoreRecordZoneName = user.scoreRecordZoneName
        self.scoreRecordRecordName = user.scoreRecordRecordName
        self.scoreRecordPublicShareURL = user.scoreRecordPublicShareURL
    }
}
