//
//  InvitationRecord.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import Foundation
import CloudKit

class InvitationRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "Invitations"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        
        let inviteeID = ModelItem<String>(key: "inviteeID")
        
        let url = ModelItem<String>(key: "url")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
