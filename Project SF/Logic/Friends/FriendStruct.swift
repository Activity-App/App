//
//  Friend.swift
//  Project SF
//
//  Created by William Taylor on 13/7/20.
//

import CloudKit

struct ExternalUser: Hashable, Identifiable {
    
    let id = UUID()
    
    let username: String
    let name: String
    let bio: String
    let profilePictureURL: String
    let activityRings: ActivityRings
    
    let publicUserRecordID: CKRecord.ID?
    let privateUserRecordID: CKRecord.ID
    
    init(username: String, name: String, bio: String, profilePictureURL: String, activityRings: ActivityRings, publicUserRecordID: CKRecord.ID? = nil, privateUserRecordID: CKRecord.ID) {
        self.username = username
        self.name = name
        self.bio = bio
        self.profilePictureURL = profilePictureURL
        self.activityRings = activityRings
        self.publicUserRecordID = publicUserRecordID
        self.privateUserRecordID = privateUserRecordID
    }
}
