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
    private let userController = UserController()
    
    @Published var friends: [Friend] = [
        Friend(name: "christian", username: "priva28", profilePicture: nil, userRecordID: CKRecord.ID(recordName: "_ca83d0962e8569057e2d4bece6c0a335")),
        Friend(name: "simulator", username: "11promax", profilePicture: nil, userRecordID: CKRecord.ID(recordName: "_9f53c520a678dda39e348fb0624c49c2"))
    ]
    
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
    
    /// Creates user activity record for current user as well as a share and saves it to the private db.
    /// - Parameter handler: What to do when the operation completes.
    func beginSharing(then handler: @escaping (Error?) -> Void) {
        
        /// Create new randomized zone in your private db to share your activity data.
        CloudKitStore.shared.createZone { result in
            switch result {
            case .success(let zone):
                /// Create an empty `UserActivityRecord` in the created zone.
                let activityRecord = UserActivityRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                
                /// Create a share from the created activity record and set the public permission to none so no one can access it unless we explicitly allow them.
                let share = CKShare(rootRecord: activityRecord.record)
                share.publicPermission = .none
                
                /// Save the activity record and share.
                let operation = CKModifyRecordsOperation(
                    recordsToSave: [activityRecord.record, share],
                    recordIDsToDelete: nil
                )
                operation.qualityOfService = .userInitiated
                
                /// Placeholder for if saving share is successful.
                var savedShare: CKShare?
                
                operation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        handler(error)
                    }
                    if let record = record as? CKShare {
                        savedShare = record
                    }
                }
                
                operation.completionBlock = {
                    guard let savedShare = savedShare, let url = savedShare.url else {
                        handler(FriendsManagerError.unknownError)
                        return
                    }
                    
                    var inviteRecords: [FriendInvitationRecord] = []
                    
                    for friend in self.friends {
                        let invite = FriendInvitationRecord()
                        invite.inviteeID = friend.userRecordID.recordName
                        invite.fromUserInfoID = self.userController.userInfoRecord?.record.recordID.recordName
                        invite.privateShareURL = url.absoluteString
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
                        
                        print("it workssss!")
                    }
                    
                    self.container.publicCloudDatabase.add(saveInvitationsOperations)
                }
                
                self.container.privateCloudDatabase.add(operation)
            case .failure(let error):
                handler(error)
                print(error)
            }
        }
    }
    
    func invite(friend: Friend, then handler: @escaping (Error?) -> Void) {
        CloudKitStore.shared.fetchRecords(with: UserActivityRecord.self, scope: .private) { result in
            switch result {
            case .success(let records):
                print(records)
            case .failure(let error):
                handler(error)
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
        guard let shareURLString = invitation.privateShareURL,
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
