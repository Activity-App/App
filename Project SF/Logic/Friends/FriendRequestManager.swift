//
//  FriendRequestManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 31/7/20.
//

import CloudKit

class FriendRequestManager {
    
    // MARK: Properties
    
    private let container = CKContainer.appDefault
    private let cloudKitStore = CloudKitStore.shared
    private let userManager = UserManager.shared
}

// MARK: Notifications

extension FriendRequestManager {
    /// Subscribe to new friend requests sent to the current user. A silent notification with the invite data will be sent and handled in the AppDelegate.
    /// - Parameter handler: What to do when the operation completes.
    func subscribeToFriendRequests(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        guard let userRecord = userManager.privateUserRecord else {
            handler(.failure(.missingRecord))
            return
        }
        let privateUserRecordName = userRecord.record.recordID.recordName
        let predicate = NSPredicate(
            format: "recipientRecordName = %@", privateUserRecordName
        )
        let subscription = CKQuerySubscription(
            recordType: "FriendRequest",
            predicate: predicate,
            options: .firesOnRecordCreation
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notification
        
        self.container.publicCloudDatabase.save(subscription) { _, error in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            handler(.success(()))
        }
    }
}

// MARK: Fetching

extension FriendRequestManager {
    /// Fetch friend requests from the public db of a specified type.
    /// - Parameters:
    ///   - type: If you want to fetch requests sent, received or both.
    ///   - handler: What to do when the operation completes. Called with a result of friend request records if a success or a CloudKitStoreError if failure.
    ///
    /// This function uses ternery operators and predicates in order to fetch the right friend request records. It is just a basic fetch with some predicate logic.
    func fetchFriendRequests(type: FriendRequestType, then handler: @escaping (Result<[FriendRequestRecord], CloudKitStoreError>) -> Void) {
        /// Get current user.
        guard let userRecord = userManager.privateUserRecord else {
            handler(.failure(.missingRecord))
            return
        }
        
        /// Fetch only friend requests that have been sent or received not accepted.
        let recordNamePredicate = NSPredicate(
            format: type == .received ? "recipientPrivateUserRecordName == %@" : "creatorPrivateUserRecordName == %@",
            userRecord.record.recordID.recordName
        )
        let acceptedPredicate = NSPredicate(format: "accepted == false")
        let allPredicates = [recordNamePredicate, acceptedPredicate]
        
        let predicate = type == .all ?
            NSPredicate(value: true) :
            NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        
        cloudKitStore.fetchRecords(with: FriendRequestRecord.self, predicate: predicate, scope: .public) { result in
            switch result {
            case .success(let friendRequests):
                handler(.success(friendRequests))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Enum used to specify which type of friend requests you would like to fetch in `fetchFriendRequests`.
    enum FriendRequestType {
        /// Requests sent by user.
        case sent
        /// Requests sent to user.
        case received
        /// All requests.
        case all
    }
}

// MARK: Inviting

extension FriendRequestManager {
    /// Create a singular friend request to a friend and save it to the public db.
    /// - Parameters:
    ///   - friend: The friend you would like to invite.
    ///   - handler: What to do when the operation completes.
    ///
    /// See the `invite(friends: [Friends])` method for more documentation.
    func invite(user: String, then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        invite(users: [user], then: handler)
    }
    
    /// Creates friend requests for each friend in the array of friends input in the public db.
    /// - Parameters:
    ///   - users: The users you would like to invite. Array of private user record names.
    ///   - handler: What to do when the operation completes.
    ///
    /// We use a `CKFetchShareMetadataOperation` to get the metadata for the current users share URL. This metadata includes the share itself. We then convert the friends into CKShare.Participants and add them to the share as participants that can read only. The changes to the share are then saved. Upon completion of adding the participants to the share, we create the friend requests to be stored in the public db so other users can see if they have pending friend requests in which they can accept from the share url. It is ok to make this public as the public permission for the share is set to none and only people we have added as participants will be able to read the data.
    func invite(users: [String], then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        /// Get the current user record.
        guard let user = userManager.privateUserRecord else { handler(.failure(.missingRecord)); return }
        
        /// Get the friend share url from the fetched user record.
        guard let shareURLString = user.friendShareURL,
              let shareURL = URL(string: shareURLString) else {
            handler(.failure(.unknownError))
            return
        }

        self.cloudKitStore.fetchShare(with: shareURL) { result in
            switch result {
            case .success(let share):
                
                /// Convert friends into CKShare Participants.
                self.cloudKitStore.fetchShareParticipantsFromRecordNames(users: users) { result in
                    switch result {
                    case .success(let participants):
                        /// Set the friends to have read access to the share. This will let them access your shared user data.
                        for participant in participants {
                            participant.permission = .readOnly
                            share.addParticipant(participant)
                        }
                        
                        self.cloudKitStore.saveRecord(share, scope: .private) { result in
                            switch result {
                            case .success:
                                /// Invite the friends by creating an invite with the friends user record name and save it to the public db.
                                var inviteRecords: [FriendRequestRecord] = []
                                
                                for userRecordName in users {
                                    let invite = FriendRequestRecord()
                                    invite.recipientPrivateUserRecordName = userRecordName
                                    invite.creatorPublicUserRecordName = user.publicUserRecordName
                                    invite.creatorPrivateUserRecordName = user.record.recordID.recordName
                                    invite.creatorShareURL = share.url?.absoluteString
                                    invite.accepted = false
                                    inviteRecords.append(invite)
                                }
                                
                                self.cloudKitStore.saveRecords(inviteRecords.map { $0.record }, scope: .public) { result in
                                    switch result {
                                    case .success:
                                        handler(.success(()))
                                    case .failure(let error):
                                        handler(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: Accepting

extension FriendRequestManager {
    /// Fetches requests that the user has sent and accepted by the recipient. It saves the recipients share url to the list of friend share urls and then deletes the friend request record.
    /// - Parameter handler: What to do when the operation completes. This will be called with a result.
    func cleanAcceptedRequests(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        /// Get current user.
        guard let privateUserRecord = userManager.privateUserRecord,
              let publicUserRecordName = privateUserRecord.publicUserRecordName
        else {
            handler(.failure(.missingRecord))
            return
        }
        
        /// Create a predicate that will only fetch records that have been sent and accepted.
        let creatorPredicate = NSPredicate(format: "creatorPrivateUserRecordName = %@", publicUserRecordName)
        let recipientShareURLPredicate = NSPredicate(format: "recipientShareURL != nil")
        let acceptedPredicate = NSPredicate(format: "accepted == true")
        let allPredicates = [creatorPredicate, recipientShareURLPredicate, acceptedPredicate]
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        
        self.cloudKitStore.fetchRecords(with: FriendRequestRecord.self, predicate: predicate, scope: .public) { result in
            switch result {
            case .success(let friendRequests):
                /// If there are no results then there is nothing to do and therefore the operation is a success.
                guard !friendRequests.isEmpty else { handler(.success(())); return }
                
                for friendRequest in friendRequests {
                    /// Make friendShareURLs empty if it is nil.
                    if privateUserRecord.friendShareURLs == nil {
                        privateUserRecord.friendShareURLs = []
                    }
                    /// Add the friend request recipient share url to the users array of friends share urls.
                    privateUserRecord.friendShareURLs?.append(friendRequest.recipientShareURL!)
                    self.userManager.savePrivateUserRecord(privateUserRecord) { result in
                        switch result {
                        case .success:
                            ///** The two users are now successfully friends yay! We can now safely delete the friend request from the public db. **
                            let friendRequestRecordID = friendRequest.record.recordID
                            self.cloudKitStore.deleteRecord(with: friendRequestRecordID, scope: .public) { result in
                                switch result {
                                case .success:
                                    /// If it is the last friend request in the list and it's all a success, we complete with a success.
                                    if friendRequests.last?.record.recordID.recordName == friendRequest.record.recordID.recordName {
                                        handler(.success(()))
                                    }
                                case .failure(let error):
                                    handler(.failure(error))
                                    return
                                }
                            }
                        case .failure(let error):
                            handler(.failure(error))
                            return
                        }
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Accept a pending friend request that was sent to the current user.
    /// - Parameters:
    ///   - friendRequest: The friend request to accept.
    ///   - handler: What to do when the operation completes. Called with a result that is void if a success or a CloudKitStoreError if failure.
    func acceptFriendRequest(
        _ friendRequest: FriendRequestRecord,
        handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        /// Get current user.
        guard let userRecord = userManager.privateUserRecord else {
            handler(.failure(.missingRecord))
            return
        }
        
        /// Get the share url to the friend request creator. Leads to their SharedUserRecord. Also get the current user share url to their SharedUserRecord.
        guard let creatorShareURLString = friendRequest.creatorShareURL,
              let creatorShareURL = URL(string: creatorShareURLString),
              let friendShareURLString = userRecord.friendShareURL,
              let friendShareURL = URL(string: friendShareURLString)
        else {
            handler(.failure(.unknownError))
            return
        }
        
        /// Fetch the users share so we can add the person who created the friend request as a participant to the share and therefore give them access to the SharedUserRecord.
        self.cloudKitStore.fetchShare(with: friendShareURL) { result in
            switch result {
            case .success(let share):
                guard let privateUserRecordName = friendRequest.creatorPrivateUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                /// Convert the creators record name into a CKShare Participant.
                self.cloudKitStore.fetchShareParticipantsFromRecordNames(users: [privateUserRecordName]) { result in
                    switch result {
                    case .success(let participants):
                        /// Add to users share.
                        for participant in participants {
                            participant.permission = .readOnly
                            share.addParticipant(participant)
                        }
                        
                        ///** Now we have to save the creators share url to our friend share url list to refer back to later when we want to read their data. **
                        
                        /// Make friendShareURLs empty if it is nil.
                        if userRecord.friendShareURLs == nil {
                            userRecord.friendShareURLs = []
                        }
                        /// Add the friend request creators share url to the users array of friends share urls.
                        userRecord.friendShareURLs!.append(creatorShareURL.absoluteString)
                        
                        self.cloudKitStore.saveRecords([share, userRecord.record], scope: .private) { result in
                            switch result {
                            case .success:
                                ///** Now that we have given them access to the users SharedUserRecord, we need to let them know we have done so. We do this by setting the invitation to accepted and adding our share url so they can then save and access it later. **
                                friendRequest.recipientShareURL = userRecord.friendShareURL
                                friendRequest.accepted = true
                                self.cloudKitStore.saveRecord(friendRequest.record, scope: .public) { result in
                                    switch result {
                                    case .success:
                                        self.cloudKitStore.saveRecord(share, scope: .private) { result in
                                            switch result {
                                            case .success:
                                                handler(.success(()))
                                            case .failure(let error):
                                                handler(.failure(error))
                                            }
                                        }
                                    case .failure(let error):
                                        handler(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
