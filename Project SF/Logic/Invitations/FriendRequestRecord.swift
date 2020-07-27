//
//  FriendRequestRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

class FriendRequestRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "FriendRequest"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        let inviteeRecordName = ModelItem<String>(key: "inviteeRecordName")
        let fromUserInfoWithRecordName = ModelItem<String>(key: "fromUserInfoWithRecordName")
        let shareURL = ModelItem<String>(key: "shareURL")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
