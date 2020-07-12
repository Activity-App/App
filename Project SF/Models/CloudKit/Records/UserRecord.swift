//
//  User.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import Foundation
import CloudKit

class UserRecord {
    
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
    
    init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: Key
    
    enum Key: String {
        case nickname
        case phoneNumberHash
        case bio
    }

}

private extension CKRecord {
    
    subscript(_ key: UserRecord.Key) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? __CKRecordObjCValue
        }
    }
    
}
