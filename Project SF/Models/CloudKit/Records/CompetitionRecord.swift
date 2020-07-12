//
//  CompetitionRecord.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

class CompetitionRecord: Record {
    
    // MARK: Properties
    
    static let type = "Competitions"

    let record: CKRecord

    var type: ChallengeType? {
        get { ChallengeType(rawValue: record[Key.type] as? Int ?? -1) }
        set { record[Key.type] = newValue?.rawValue }
    }
    
    var startDate: Date? {
        get { record[Key.startDate] as? Date }
        set { record[Key.startDate] = newValue }
    }
    
    var endDate: Date? {
        get { record[Key.endDate] as? Date }
        set { record[Key.endDate] = newValue }
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: Key
    
    private enum Key: String, RecordKey {
        case type
        case startDate
        case endDate
    }
    
    // MARK: ChallengeType
    
    enum ChallengeType: Int {
        case move = 0
    }

}
