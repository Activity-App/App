//
//  Friend.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import CloudKit

struct Friend: Hashable {
    let userInfoRecordID: CKRecord.ID?
    let userRecordID: CKRecord.ID
    
    init(userInfoRecordID: CKRecord.ID? = nil, userRecordID: CKRecord.ID) {
        self.userInfoRecordID = userInfoRecordID
        self.userRecordID = userRecordID
    }
}
