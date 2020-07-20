//
//  RecordKey.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

protocol RecordKey {
    
    var rawValue: String { get }
    
}

extension CKRecord {
    
    subscript(_ key: RecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? __CKRecordObjCValue
        }
    }
    
}
