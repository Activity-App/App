//
//  FriendsManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import CloudKit

class FriendsManager {
    
    // MARK: Properties
    
    private let container: CKContainer
    private let userController = UserController()
    
    var friends: [Friend] = [
        Friend(name: "christian", username: "priva28", profilePicture: nil, recordID: CKRecord.ID(recordName: "_ca83d0962e8569057e2d4bece6c0a335")),
        Friend(name: "simulator", username: "11promax", profilePicture: nil, recordID: CKRecord.ID(recordName: "_9f53c520a678dda39e348fb0624c49c2"))
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
                                    let friend = Friend(
                                        name: user.name ?? "",
                                        username: user.username ?? "",
                                        profilePicture: URL(string: user.profilePictureURL ?? ""),
                                        recordID: CKRecord.ID(recordName: user.userRecordID ?? "")
                                    )
                                    friends.append(friend)
                                    
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
    
    func beginSharing() {
        CloudKitStore.shared.createZone { result in
            switch result {
            case .success(let zone):
                self.fetchShareParticipantsFrom(friends: self.friends) { result in
                    switch result {
                    case .success(let participants):
                        let activityRecord = UserActivityRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                        activityRecord.move = 28
                        
                        let share = CKShare(rootRecord: activityRecord.record)
                        print("herrrre")
                        share.publicPermission = .none
                        
                        for participant in participants.map({ $0.0 }) {
                            participant.permission = .readOnly
                            share.addParticipant(participant)
                        }
                        
                        let operation = CKModifyRecordsOperation(
                            recordsToSave: [activityRecord.record, share],
                            recordIDsToDelete: nil
                        )
                        operation.qualityOfService = .userInitiated
                        
                        var savedShare: CKShare?
                        
                        operation.perRecordCompletionBlock = { record, error in
                            if let record = record as? CKShare {
                                savedShare = record
                            }
                        }
                        
                        operation.completionBlock = {
                            guard let savedShare = savedShare, let url = savedShare.url else {
                                print("you're dumb and this is messed up")
                                return
                            }
                            
                            var inviteRecords: [FriendInvitationRecord] = []
                            
                            for friend in self.friends {
                                let invite = FriendInvitationRecord()
                                invite.inviteeID = friend.recordID.recordName
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
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
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
                                                                        friends.map { (key: $0.recordID, value: $0) })
        let friendLookupInfomation = friends.map { CKUserIdentity.LookupInfo(userRecordID: $0.recordID) }
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
