//
//  CompetitionInvitationRecord.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import CloudKit

class CompetitionInvitationRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "CompetitionInvitation"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        
        let inviteeID = ModelItem<String>(key: "inviteeID")
        
        let competitionRecordInviteURL = ModelItem<String>(key: "competitionRecordInviteURL")
        
        let scoreURLHolderInviteURL = ModelItem<String>(key: "scoreURLHolderInviteURL")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
