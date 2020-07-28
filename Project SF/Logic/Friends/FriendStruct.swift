//
//  Friend.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import CloudKit

struct Friend: Hashable {
    let publicUserRecordID: CKRecord.ID?
    let privateUserRecordID: CKRecord.ID
    
    init(publicUserRecordID: CKRecord.ID? = nil, privateUserRecordID: CKRecord.ID) {
        self.publicUserRecordID = publicUserRecordID
        self.privateUserRecordID = privateUserRecordID
    }
}
