//
//  ScoreRecord.swift
//  Project SF
//
//  Created by William Taylor on 14/7/20.
//

import Foundation
import CloudKit

class ScoreRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "Scores"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Model
    
    struct Model {
        
        let placeholder = ModelItem<Int>(key: "placeholder")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}

