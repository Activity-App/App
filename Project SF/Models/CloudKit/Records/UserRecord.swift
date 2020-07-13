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
    
    // MARK: Model
    
    struct Model {
        
        let nickname = ModelItem<String>(key: "nickname")
        
        let bio = ModelItem<String>(key: "bio")
        
        let profilePictureURL = ModelItem<String>(key: "profilePictureURL")
        
    }
    
    // MARK: Init
    
    required init(record: CKRecord) {
        self.record = record
    }

}
