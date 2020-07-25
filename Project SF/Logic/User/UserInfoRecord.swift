//
//  UserInfoRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

class UserInfoRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "UserInfo"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        let name = ModelItem<String>(key: "name")
        let username = ModelItem<String>(key: "username")
        let bio = ModelItem<String>(key: "bio")
        let profilePictureURL = ModelItem<String>(key: "profilePictureURL")
        let userRecordID = ModelItem<String>(key: "userRecordID")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
