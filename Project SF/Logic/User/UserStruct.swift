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
    
    /// The record name of the private user associated with this user. `UserRecord`
    var privateUserRecordName: String?
    
    /// The record name of the public user associated with this user. `PublicUserRecord`
    var publicUserRecordName: String?
    
    /// The record name of the shared user associated with this user. `SharedUserRecord`
    var sharedUserRecordName: String?
    
    /// A list of share URL's leading to the users friends `SharedUserRecord`s
    var friendShareURLs: [String]?
    
    /// The URL that leads to the share holding the users `SharedUserRecord`
    var friendShareURL: String?
    
    var scoreRecordZoneName: String?
    var scoreRecordRecordName: String?
    var scoreRecordPublicShareURL: String?
    
    var type: BasedOn
    
    init(
        name: String? = nil,
        username: String,
        bio: String? = nil,
        profilePictureURL: String? = nil,
        privateUserRecordName: String? = nil,
        publicUserRecordName: String? = nil,
        sharedUserRecordName: String? = nil,
        friendShareURLs: [String]? = nil,
        friendShareURL: String? = nil,
        scoreRecordZoneName: String? = nil,
        scoreRecordRecordName: String? = nil,
        scoreRecordPublicShareURL: String? = nil
    ) {
        self.name = name
        self.username = username
        self.bio = bio
        self.profilePictureURL = profilePictureURL
        self.privateUserRecordName = privateUserRecordName
        self.publicUserRecordName = publicUserRecordName
        self.sharedUserRecordName = sharedUserRecordName
        self.friendShareURLs = friendShareURLs
        self.friendShareURL = friendShareURL
        self.scoreRecordZoneName = scoreRecordZoneName
        self.scoreRecordRecordName = scoreRecordRecordName
        self.scoreRecordPublicShareURL = scoreRecordPublicShareURL
        self.type = .custom
    }
    
    init(privateUserRecord: UserRecord) {
        self.name = privateUserRecord.name
        self.username = privateUserRecord.username
        self.bio = privateUserRecord.bio
        self.profilePictureURL = privateUserRecord.profilePictureURL
        self.privateUserRecordName = privateUserRecord.record.recordID.recordName
        self.publicUserRecordName = privateUserRecord.publicUserRecordName
        self.sharedUserRecordName = privateUserRecord.sharedUserRecordName
        self.friendShareURLs = privateUserRecord.friendShareURLs
        self.friendShareURL = privateUserRecord.friendShareURL
        self.scoreRecordZoneName = privateUserRecord.scoreRecordZoneName
        self.scoreRecordRecordName = privateUserRecord.scoreRecordRecordName
        self.scoreRecordPublicShareURL = privateUserRecord.scoreRecordPublicShareURL
        self.type = .privateUser
    }
    
    init(publicUserRecord: PublicUserRecord) {
        self.name = publicUserRecord.name
        self.username = publicUserRecord.username
        self.bio = publicUserRecord.bio
        self.profilePictureURL = publicUserRecord.profilePictureURL
        self.privateUserRecordName = publicUserRecord.privateUserRecordName
        self.publicUserRecordName = publicUserRecord.record.recordID.recordName
        self.sharedUserRecordName = nil
        self.friendShareURLs = nil
        self.friendShareURL = nil
        self.scoreRecordZoneName = nil
        self.scoreRecordRecordName = nil
        self.scoreRecordPublicShareURL = nil
        self.type = .publicUser
    }
    
    mutating func updateWith(privateUserRecord: UserRecord) {
        name = privateUserRecord.name
        username = privateUserRecord.username
        bio = privateUserRecord.bio
        profilePictureURL = privateUserRecord.profilePictureURL
        privateUserRecordName = privateUserRecord.record.recordID.recordName
        publicUserRecordName = privateUserRecord.publicUserRecordName
        sharedUserRecordName = privateUserRecord.sharedUserRecordName
        friendShareURLs = privateUserRecord.friendShareURLs
        friendShareURL = privateUserRecord.friendShareURL
        scoreRecordZoneName = privateUserRecord.scoreRecordZoneName
        scoreRecordRecordName = privateUserRecord.scoreRecordRecordName
        scoreRecordPublicShareURL = privateUserRecord.scoreRecordPublicShareURL
        type = .privateUser
    }
    
    mutating func updateWith(publicUserRecord: PublicUserRecord) {
        name = publicUserRecord.name
        username = publicUserRecord.username
        bio = publicUserRecord.bio
        profilePictureURL = publicUserRecord.profilePictureURL
        privateUserRecordName = publicUserRecord.privateUserRecordName
        publicUserRecordName = publicUserRecord.record.recordID.recordName
    }
    
    enum BasedOn {
        case privateUser
        case publicUser
        case both
        case custom
    }
}
