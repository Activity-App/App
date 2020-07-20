//
//  ScoreURLHolderRecord.swift
//  Project SF
//
//  Created by William Taylor on 14/7/20.
//

import Foundation
import CloudKit

/// A record that holds an invite link for a shared ScoreRecord.
class ScoreURLHolderRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "ScoreURLHolders"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        
        let isSet = ModelItem<Bool>(key: "isSet")
        
        let url = ModelItem<String>(key: "url")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
