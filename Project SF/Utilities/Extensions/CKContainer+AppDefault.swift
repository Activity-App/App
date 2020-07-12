//
//  CKContainer+AppDefault.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

extension CKContainer {
    
    static var appDefault: CKContainer {
        return CKContainer(identifier: "iCloud.com.wfltaylor.projectsf")
    }
    
}
