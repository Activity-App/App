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
        let inviteePrivateUserRecordName = ModelItem<String>(key: "inviteePrivateUserRecordName")
        let inviteeShareURL = ModelItem<String>(key: "inviteeShareURL")
        
        let creatorPublicUserRecordName = ModelItem<String>(key: "creatorPublicUserRecordName")
        let creatorPrivateUserRecordName = ModelItem<String>(key: "creatorPrivateUserRecordName")
        let creatorShareURL = ModelItem<String>(key: "creatorShareURL")
        
        let accepted = ModelItem<Bool>(key: "accepted")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
