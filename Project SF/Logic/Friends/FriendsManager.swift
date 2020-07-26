//
//  FriendsManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import CloudKit

class FriendsManager: ObservableObject {
    
    // MARK: Properties
    
    private let container: CKContainer
    private let cloudKitStore = CloudKitStore.shared
    private let userController = UserController()
    
    @Published var friends: [Friend] = [
        Friend(userRecordID: CKRecord.ID(recordName: "_ca83d0962e8569057e2d4bece6c0a335")),
        Friend(userRecordID: CKRecord.ID(recordName: "_9f53c520a678dda39e348fb0624c49c2"))
    ]
    
    @Published var sharingPermission = false
    
    init(container: CKContainer = .appDefault) {
        self.container = container
    }
    
    /// Requests permission from the user to discover their contacts.
    /// - Parameter handler: The result handler. Not guaranteed to be executed on the main thread.
    /// - Tag: requestDiscoveryPermission
    func requestDiscoveryPermission(then handler: @escaping (Result<Bool, Error>) -> Void) {
        container.requestApplicationPermission([.userDiscoverability]) { (status, error) in
            if let error = error {
                handler(.failure(error))
                return
            }
            switch status {
            case .granted:
                handler(.success(true))
            case .denied:
                handler(.success(false))
            default:
                handler(.failure(FriendsManagerError.unknownError))
            }
        }
    }
    
    /// Asynchronously discovers the users friends. Fails if the adequate permissions have not been granted (you can request the required permission using [requestDiscoveryPermission](x-source-tag://requestDiscoveryPermission).
    /// - Parameter handler: The result handler. Not guaranteed to be executed on the main thread.
    func discoverFriends(then handler: @escaping (Result<[Friend], Error>) -> Void) {
        container.status(forApplicationPermission: .userDiscoverability) { [weak container] status, error in
            guard let container = container else { return }
            if let error = error {
                handler(.failure(error))
                return
            }
            if case .granted = status {
                container.discoverAllIdentities { identities, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let identities = identities else {
                        handler(.failure(FriendsManagerError.unknownError))
                        return
                    }
                    print(identities)
                    
                    var friends: [Friend] = []
                    
                    for identity in identities {
                        let recordID = identity.userRecordID?.recordName ?? ""
                        let predicate = NSPredicate(format: "userRecordID == %@", recordID)
                        
                        CloudKitStore.shared.fetchRecords(
                            with: UserInfoRecord.self,
                            predicate: predicate,
                            scope: .public
                        ) { result in
                            switch result {
                            case .success(let records):
                                for user in records {
                                    friends.append(user.asFriend())
                                    
                                    if identity == identities.last && user.record == records.last?.record {
                                        handler(.success(friends))
                                    }
                                }
                            case .failure:
                                break
                            }
                        }
                    }
                }
            } else {
                handler(.failure(FriendsManagerError.insufficientPermissions))
            }
        }
    }
    
    // ** DONT USE ANYTHING BELOW YET **
    
    /// Creates empty user activity record for current user as well as a share and saves it to the private db.
    /// - Parameter handler: What to do when the operation completes.
    func beginSharing(completion: @escaping (Error?) -> Void) {
        /// Create new randomized zone in your private db to share your activity data.
        cloudKitStore.createZone(named: "SharedToFriendsDataZone") { result in
            switch result {
            case .success(let zone):
                /// Create an empty `UserActivityRecord` in the created zone.
                let userInfo = UserInfoRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                let activityRecord = UserActivityRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                
                /// Create a share from the created activity record and set the public permission to none so no one can access it unless we explicitly allow them.
                let share = CKShare(rootRecord: activityRecord.record)
                share.publicPermission = .none
                
                /// Operation to save the activity record and share.
                let operation = CKModifyRecordsOperation(
                    recordsToSave: [userInfo.record, activityRecord.record, share],
                    recordIDsToDelete: nil
                )
                operation.qualityOfService = .userInitiated
                
                /// Placeholder for if saving share is successful.
                var savedShare: CKShare?
                
                operation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        completion(error)
                    }
                    if let record = record as? CKShare {
                        savedShare = record
                    }
                }
                
                operation.completionBlock = {
                    guard let savedShare = savedShare, let url = savedShare.url else {
                        completion(FriendsManagerError.unknownError)
                        return
                    }
                    
                    /// Save the saved share url to the user record so it can be accessed later.
                    self.cloudKitStore.fetchUserRecord { result in
                        switch result {
                        case .success(let record):
                            record.friendShareURL = url.absoluteString
                            self.cloudKitStore.saveUserRecord(record) { result in
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
                }
                
                self.container.privateCloudDatabase.add(operation)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func invite(friends: [Friend], completion: @escaping (Error?) -> Void) {
        /// Get the current user record.
        cloudKitStore.fetchUserRecord { result in
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
                    guard let shareURLMetadata = shareMetadata.first(where: { $0.share.url == shareURL }) else { return }
                    let share = shareURLMetadata.share
                    
                    /// Convert friends into CKShare Participants.
                    self.fetchShareParticipantsFrom(friends: friends) { result in
                        switch result {
                        case .success(let participants):
                            
                            /// Set the friends to have read access to the share. This will let them access your activity data.
                            for participant in participants.map({ $0.0 }) {
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
                                var inviteRecords: [FriendInvitationRecord] = []
                                
                                for friend in friends {
                                    let invite = FriendInvitationRecord()
                                    invite.inviteeRecordName = friend.userRecordID.recordName
                                    invite.fromUserInfoWithRecordName = self.userController.userInfoRecord?.record.recordID.recordName
                                    invite.shareURL = url.absoluteString
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
    
    func subscribeToFriendRequests(completion: @escaping (Error?) -> Void) {
        cloudKitStore.fetchUserRecord { result in
            switch result {
            case .success(let record):
                let predicate = NSPredicate(format:"inviteeRecordName = %@", record.record.recordID.recordName)
                let subscription = CKQuerySubscription(recordType: "FriendInvitation", predicate: predicate, options: .firesOnRecordCreation)
                
                let notification = CKSubscription.NotificationInfo()
                notification.alertBody = "Someone added you as a friend!"
                notification.soundName = "default"
                notification.shouldBadge = true
                notification.title = "New Friend!"
                
                subscription.notificationInfo = notification
                
                self.container.publicCloudDatabase.save(subscription) { result, error in
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
    
    func fetchFriendRequest() {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                print(error)
            }
            guard let recordID = recordID else {
                print("something dumb")
                return
            }
            
            // find invitations in the public database matching the users record id
            let operation = CKQueryOperation(query: CKQuery(recordType: FriendInvitationRecord.type,
                                                            predicate: NSPredicate(format: "inviteeID == %@",
                                                                                   recordID.recordName)))
            operation.qualityOfService = .userInitiated
            var invitationRecords: [FriendInvitationRecord] = []
            
            operation.recordFetchedBlock = { record in
                invitationRecords.append(FriendInvitationRecord(record: record))
            }
            
            operation.queryCompletionBlock = { _, error in
                if let error = error {
                    print(error)
                    return
                }
                if invitationRecords.count == 0 {
                    print("no friends oof")
                    return
                }
                self.acceptFriendRequest(invitation: invitationRecords.first!)
                print("found 1")
            }
            
            self.container.publicCloudDatabase.add(operation)
        }
    }
    
    func acceptFriendRequest(invitation: FriendInvitationRecord) {
        guard let shareURLString = invitation.shareURL,
              let shareURL = URL(string: shareURLString) else {
            return
        }
        
        let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [shareURL])
        metadataFetchOperation.qualityOfService = .userInitiated
        
        var shareMetadata: [CKShare.Metadata] = []
        
        metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            if let error = error {
                print(error)
                return
            }
            guard let metadata = metadata else { return }
            shareMetadata.append(metadata)
        }
        
        metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                print(error)
            }
            let shareURLMetadata = shareMetadata.first { $0.share.url == shareURL }
            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: shareMetadata)
            acceptOperation.qualityOfService = .userInitiated
            
            acceptOperation.acceptSharesCompletionBlock = { error in
                if let error = error {
                    print(error)
                    return
                }
                let fetchURLHolderOperation = CKFetchRecordsOperation(recordIDs: [shareURLMetadata!.rootRecordID])
                fetchURLHolderOperation.qualityOfService = .userInitiated
                fetchURLHolderOperation.fetchRecordsCompletionBlock = { records, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let recordRaw = records?.first?.value else {
                        print("Oh no....")
                        return
                    }
                    let record = UserActivityRecord(record: recordRaw)
                    print(record.move!)
                }
                
                self.container.sharedCloudDatabase.add(fetchURLHolderOperation)
            }
            
            self.container.add(acceptOperation)
        }
        container.add(metadataFetchOperation)
    }
    
    /// Fetches share participants that can be used with a CKShare.
    private func fetchShareParticipantsFrom(
        friends: [Friend],
        then handler: @escaping (Result<[(CKShare.Participant, Friend)], Error>) -> Void
    ) {
        let friendForUserRecordID: [CKRecord.ID: Friend] = Dictionary(uniqueKeysWithValues:
                                                                        friends.map { (key: $0.userRecordID, value: $0) })
        let friendLookupInfomation = friends.map { CKUserIdentity.LookupInfo(userRecordID: $0.userRecordID) }
        let participantLookupOperation = CKFetchShareParticipantsOperation(userIdentityLookupInfos:
                                                                            friendLookupInfomation)
        participantLookupOperation.qualityOfService = .userInitiated
        
        var participants = [CKShare.Participant]()
        
        participantLookupOperation.shareParticipantFetchedBlock = { participant in
            participants.append(participant)
        }
        
        participantLookupOperation.fetchShareParticipantsCompletionBlock = { error in
            if let error = error, participants.count == 0 {
                handler(.failure(error))
                return
            }
            
            let returnValue: [(CKShare.Participant, Friend)] = participants
                .compactMap { participant in
                    if let id = participant.userIdentity.userRecordID, let friend = friendForUserRecordID[id] {
                        return (participant, friend)
                    } else {
                        return nil
                    }
                }
            
            handler(.success(returnValue))
        }
        self.container.add(participantLookupOperation)
    }
    
    // MARK: Friends Manager Error
    
    enum FriendsManagerError: Error {
        case unknownError
        case insufficientPermissions
    }
}
