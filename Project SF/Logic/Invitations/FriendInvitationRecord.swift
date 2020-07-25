//
//  FriendInvitationRecord.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

import CloudKit

class FriendInvitationRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "FriendInvitation"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        let inviteeID = ModelItem<String>(key: "inviteeID")
        let fromUserInfoID = ModelItem<String>(key: "fromUserInfoID")
        let privateShareURL = ModelItem<String>(key: "privateShareURL")
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
