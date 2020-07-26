//
//  UserStruct.swift
//  Project SF
//
//  Created by Christian Privitelli on 25/7/20.
//

/// A user represented as a struct that can be used more easily in the UI. All values are optional so it is flexible to initialise with only the values you want.
struct User {
    var name: String?
    var username: String?
    var bio: String?
    var profilePictureURL: String?
    var scoreRecordZoneName: String?
    var scoreRecordRecordName: String?
    var scoreRecordPublicShareURL: String?
    
    /// The URL that leads to the share holding the users `UserActivityRecord`
    var friendShareURL: String?
}
