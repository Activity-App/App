//
//  Record.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation
import CloudKit

protocol Record {
    
    static var type: CKRecord.RecordType { get }
    
    var record: CKRecord { get }
    
    init(record: CKRecord)

}

extension Record {
    
    init() {
        self.init(record: CKRecord(recordType: Self.type))
    }
    
}
