//
//  User.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import Foundation
import CloudKit

class UserRecord: DynamicRecord {
    
    // MARK: Properties
    
    static let type = "Users"
    
    static let model = Model()

    let record: CKRecord
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }
    
    // MARK: Model
    
    struct Model: ModelProtocol {
        
        let nickname = ModelItem<String>(key: "nickname")
                
        let phoneNumberHash = ModelItem<String>(key: "phoneNumberHash")
        
        let bio = ModelItem<String>(key: "bio")
        
    }

}
