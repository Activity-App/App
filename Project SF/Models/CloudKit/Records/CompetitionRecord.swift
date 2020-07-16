//
//  CompetitionRecord.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

class CompetitionRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "Competitions"
    
    static let model = Model()

    let record: CKRecord

    // manually map from Int to ChallengeType
    var type: CompetitionType? {
        get { CompetitionType(rawValue: self[dynamicMember: \.type] ?? -1) }
        set { self[dynamicMember: \.type] = newValue?.rawValue }
    }
    
    // MARK: Model
    
    struct Model {
        
        let type = ModelItem<Int>(key: "type")
        
        let startDate = ModelItem<Date>(key: "startDate")
        
        let endDate = ModelItem<Date>(key: "endDate")
        
        let scoreURLHolderShareURLs = ModelItem<[String]>(key: "scoreURLHolderShareURLs")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: CompetitionType
    
    enum CompetitionType: Int {
        case move = 0
    }

}
