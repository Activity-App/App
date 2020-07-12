//
//  User.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import Foundation
import CloudKit

class UserRecord: Record {
    
    // MARK: Properties
    
    static let type = "Users"

    let record: CKRecord

    var nickname: String? {
        get { record[Key.nickname] as? String }
        set { record[Key.nickname] = newValue }
    }
    
    var phoneNumberHash: String? {
        get { record[Key.phoneNumberHash] as? String }
        set { record[Key.phoneNumberHash] = newValue }
    }
    
    var bio: String? {
        get { record[Key.bio] as? String }
        set { record[Key.bio] = newValue }
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: Key
    
    enum Key: String, RecordKey {
        case nickname
        case phoneNumberHash
        case bio
    }

}
