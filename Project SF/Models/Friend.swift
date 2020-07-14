//
//  Friend.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import Foundation
import CloudKit

struct Friend: Hashable {
    
    let name: String
    
    let profilePicture: URL?
    
    let recordID: CKRecord.ID
    
}
