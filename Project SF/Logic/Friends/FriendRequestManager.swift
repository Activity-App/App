//
//  FriendRequestManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 31/7/20.
//

import CloudKit

class FriendRequestManager {
    
    private let container = CKContainer.appDefault
    private let cloudKitStore = CloudKitStore.shared
    private let userManager = UserManager.shared
    
    /// Create a singular friend request to a friend and save it to the public db.
    /// - Parameters:
    ///   - friend: The friend you would like to invite.
    ///   - completion: What to do when the operation completes.
    ///
    /// See the `invite(friends: [Friends])` method for more documentation.
    func invite(user: String, completion: @escaping (Error?) -> Void) {
        invite(users: [user], completion: completion)
    }
    
    /// Creates friend requests for each friend in the array of friends input in the public db.
    /// - Parameters:
    ///   - users: The users you would like to invite. Array of private user record names.
    ///   - completion: What to do when the operation completes.
    ///
    /// For this function to work correctly, a CKShare containing data to share with friends is required. Only run this function after you are  sure you have previously run `beginSharing`, otherwise it will fail.
    ///
    /// This function starts by fetching the current user record to get the share url for the CKShare you saved previously, if you have not saved previously and the URL cannot be found, it will complete with an error. After it fetches the URL, it uses a `CKFetchShareMetadataOperation` to get the metadata for the share URL. This metadata includes the share itself. We then convert the friends into CKShare.Participants and add them to the share. The changes to the share are saved with a `CKModifyRecordsOperation`. Upon completion of adding the participants to the share, we create the requests to be stored in the public db so other users can see if they have pending friend requests in which they can accept from the share url. It is ok to make this public as the public permission for the share is set to none and only people we have added as participants will be able to read the data.
    func invite(users: [String], completion: @escaping (Error?) -> Void) {
        /// Get the current user record.
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let record):
                
                /// Get the friend share url from the fetched user record.
                guard let shareURLString = record.friendShareURL,
                      let shareURL = URL(string: shareURLString) else {
                    completion(FriendsManagerError.unknownError)
                    return
                }
                
                /// Fetch the share metadata from the friend share URL.
                let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [shareURL])
                metadataFetchOperation.qualityOfService = .userInitiated
                
                var shareMetadata: [CKShare.Metadata] = []
                
                metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
                    if let error = error {
                        completion(error)
                    }
                    guard let metadata = metadata else { return }
                    shareMetadata.append(metadata)
                }
                
                metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
                    if let error = error {
                        completion(error)
                    }
                    
                    /// Get the associated share from the share metadata.
                    guard
                        let shareURLMetadata = shareMetadata.first(where: { $0.share.url == shareURL })
                    else {
                        return
                    }
                    let share = shareURLMetadata.share
                    
                    /// Convert friends into CKShare Participants.
                    self.cloudKitStore.fetchShareParticipantsFromRecordNames(users: users) { result in
                        switch result {
                        case .success(let participants):
                            
                            /// Set the friends to have read access to the share. This will let them access your activity data.
                            for participant in participants {
                                participant.permission = .readOnly
                                share.addParticipant(participant)
                            }
                            
                            let operation = CKModifyRecordsOperation(
                                recordsToSave: [share],
                                recordIDsToDelete: nil
                            )
                            operation.qualityOfService = .userInitiated
                            
                            var savedShare: CKShare?
                            var shareCreationError: Error?
                            
                            operation.perRecordCompletionBlock = { record, error in
                                if let record = record as? CKShare {
                                    shareCreationError = error
                                    savedShare = record
                                }
                            }
                            
                            operation.completionBlock = {
                                if let error = shareCreationError {
                                    completion(error)
                                    return
                                }
                                guard let savedShare = savedShare, let url = savedShare.url else {
                                    completion(FriendsManagerError.unknownError)
                                    return
                                }
                                
                                /// Invite the friends by creating an invite with the friends user record name and save it to the public db.
                                var inviteRecords: [FriendRequestRecord] = []
                                
                                for userRecordName in users {
                                    let invite = FriendRequestRecord()
                                    invite.inviteePrivateUserRecordName = userRecordName
                                    invite.creatorPublicUserRecordName = record.publicUserRecordName
                                    invite.creatorShareURL = url.absoluteString
                                    invite.accepted = false
                                    inviteRecords.append(invite)
                                }
                                
                                let saveInvitationsOperations = CKModifyRecordsOperation(
                                    recordsToSave: inviteRecords.map({ $0.record }),
                                    recordIDsToDelete: nil
                                )
                                
                                saveInvitationsOperations.modifyRecordsCompletionBlock = { _, _, error in
                                    if let error = error {
                                        print(error)
                                        return
                                    }
                                    completion(nil)
                                }
                                
                                self.container.publicCloudDatabase.add(saveInvitationsOperations)
                            }
                            
                            self.container.privateCloudDatabase.add(operation)
                        case .failure(let error):
                            print(error)
                            completion(error)
                        }
                    }
                }
                self.container.add(metadataFetchOperation)
            case .failure(let error):
                print(error)
                completion(error)
            }
        }
    }
    
    /// Subscribe to new friend requests sent to the current user. A silent notification with the invite data will be sent and handled in the AppDelegate.
    /// - Parameter completion: What to do when the operation completes.
    func subscribeToFriendRequests(completion: @escaping (Error?) -> Void) {
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let record):
                let predicate = NSPredicate(
                    format: "inviteeRecordName = %@", record.record.recordID.recordName
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
                        completion(error)
                    }
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }

    func fetchFriendRequests(type: FriendRequestType, completion: @escaping (Result<[FriendRequestRecord], Error>) -> Void) {
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let userRecord):
                let recordNamePredicate = NSPredicate(
                    format: type == .received ? "inviteePrivateUserRecordName == %@" :
                                                "creatorPublicUserRecordName == %@",
                    type == .received ? userRecord.record.recordID.recordName : userRecord.publicUserRecordName ?? ""
                )
                let acceptedPredicate = NSPredicate(format: "accepted == false")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [recordNamePredicate, acceptedPredicate])
                let query = CKQuery(
                    recordType: FriendRequestRecord.type,
                    predicate: type == .all ? NSPredicate(value: true) : predicate
                )
                let operation = CKQueryOperation(query: query)
                
                operation.qualityOfService = .userInitiated
                var invitationRecords: [FriendRequestRecord] = []
                
                operation.recordFetchedBlock = { record in
                    invitationRecords.append(FriendRequestRecord(record: record))
                }
                
                operation.queryCompletionBlock = { _, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(invitationRecords))
                }
                
                self.container.publicCloudDatabase.add(operation)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchAndCleanAcceptedRequests(completion: @escaping (Error?) -> Void) {
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let privateUserRecord):
                let creatorPredicate = NSPredicate(format: "creatorPublicUserRecordName = %@", privateUserRecord.publicUserRecordName ?? "")
                let acceptedPredicate = NSPredicate(format: "accepted == true")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [creatorPredicate, acceptedPredicate])
                self.cloudKitStore.fetchRecords(with: FriendRequestRecord.self, predicate: predicate, scope: .public) { result in
                    switch result {
                    case .success(let friendRequests):
                        guard !friendRequests.isEmpty else { completion(nil); return }
                        for friendRequest in friendRequests {
                            let friendRequestRecordID = friendRequest.record.recordID
                            if friendRequest.inviteeShareURL != nil && friendRequest.accepted ?? false {
                                privateUserRecord.friendShareURLs?.append(friendRequest.inviteeShareURL!)
                                self.userManager.savePrivateUserRecord(privateUserRecord) { result in
                                    switch result {
                                    case .success:
                                        self.cloudKitStore.deleteRecord(with: friendRequestRecordID, scope: .public) { result in
                                            switch result {
                                            case .success:
                                                if friendRequests.last?.record.recordID.recordName == friendRequest.record.recordID.recordName {
                                                    completion(nil)
                                                }
                                            case .failure(let error):
                                                completion(error)
                                            }
                                        }
                                    case .failure(let error):
                                        completion(error)
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func acceptFriendRequest(invitation: FriendRequestRecord, completion: @escaping (Error?) -> Void) {
        guard let shareURLString = invitation.creatorShareURL,
              let shareURL = URL(string: shareURLString) else {
            completion(FriendsManagerError.unknownError)
            return
        }
        
        let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [shareURL])
        metadataFetchOperation.qualityOfService = .userInitiated
        
        var shareMetadata: [CKShare.Metadata] = []
        
        metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            if let error = error {
                completion(error)
                print(error)
                return
            }
            guard let metadata = metadata else { return }
            shareMetadata.append(metadata)
        }
        
        metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                completion(error)
                print(error)
            }

            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: shareMetadata)
            acceptOperation.qualityOfService = .userInitiated
            
            acceptOperation.acceptSharesCompletionBlock = { error in
                if let error = error {
                    completion(error)
                }
                self.userManager.fetchPrivateUserRecord { result in
                    switch result {
                    case .success(let userRecord):
                        if userRecord.friendShareURLs == nil {
                            userRecord.friendShareURLs = []
                        }
                        userRecord.friendShareURLs!.append(shareURL.absoluteString)
                        self.userManager.savePrivateUserRecord(userRecord) { result in
                            switch result {
                            case .success:
                                invitation.inviteeShareURL = userRecord.friendShareURL
                                invitation.accepted = true
                                self.cloudKitStore.saveRecord(invitation.record, scope: .public) { result in
                                    switch result {
                                    case .success:
                                        completion(nil)
                                    case .failure(let error):
                                        completion(error)
                                    }
                                }
                            case .failure(let error):
                                completion(error)
                            }
                        }
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
            
            self.container.add(acceptOperation)
        }
        container.add(metadataFetchOperation)
    }
    
    enum FriendsManagerError: Error {
        case unknownError
        case insufficientPermissions
    }
    
    enum FriendRequestType {
        case sent
        case received
        case all
    }
}
