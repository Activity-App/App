//
//  PublicDataRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

/// A dynamic record for saving users info. This should only be stored in the public db for the purpose of being discoverable to other users.
class PublicUserRecord: DynamicRecord {
    
    // MARK: Properties
    
    /// The type of the record that will appear in CloudKit.
    static let type = "PublicUser"
    
    static let model = Model()

    /// The user info record represented as a CKRecord that can be saved/deleted/modified to/from CloudKit.
    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
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
    
    /// A helper function that returns the current user info record as a Friend struct.
    /// - Returns: Returns the user info for name, username, profile picture as well as a CKRecord.ID for the private user record.
    func asFriend() -> Friend {
        let friend = Friend(
            username: self.username ?? "",
            name: self.name ?? "",
            bio: self.bio ?? "",
            profilePictureURL: self.profilePictureURL ?? "",
            publicUserRecordID: self.record.recordID,
            privateUserRecordID: CKRecord.ID(recordName: self.privateUserRecordName ?? "")
        )
        return friend
    }
}
