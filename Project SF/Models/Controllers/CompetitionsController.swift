//
//  CompetitionsController.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

// NOTE: This is currently a prototype and contains some poorly written code.
// TODO: Refactor into multiple classes
class CompetitionsController {
    
    // MARK: Properties
    
    private let container: CKContainer
    
    // MARK: Init
    
    init(container: CKContainer = .appDefault) {
        self.container = container
    }
    
    // MARK: Competitions
    
    /// Creates a competition.
    /// - Parameters:
    ///   - type: The competition type.
    ///   - endDate: The date the competition will end.
    ///   - friends: The friends to invite to the competition. This currently can't be changed later.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread..
    ///
    /// Internally, this creates a `CompetitionRecord` which is shared to all friend participants (with read only access). The `CompetitionRecord` contains all the competition metadata and a list of references to `ScoreURLHolderRecord`s which, if the participant has joined the competition, contain a share url that will grant access to the participants score infomation.
    func createCompetition(type: CompetitionRecord.CompetitionType,
                           endDate: Date,
                           friends: [Friend],
                           then handler: @escaping (Result<Void, Error>) -> Void) {
        // shares can't be saved to the default zone
        createZone { result in
            switch result {
            case .success(let zone):
                self.fetchShareParticipantsFrom(friends: friends) { result in
                    switch result {
                    case .success(let participants):
                        // create the main competition record
                        let competitionRecord = CompetitionRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                        competitionRecord.type = type
                        competitionRecord.startDate = Date()
                        competitionRecord.endDate = endDate
                        
                        // create the main share
                        let share = CKShare(rootRecord: competitionRecord.record)
                        share.publicPermission = .none
                        share[CKShare.SystemFieldKey.title] = "Competition"
                        
                        for participant in participants.map({ $0.0 }) {
                            // no one except the creator can edit the competition metadata
                            participant.permission = .readOnly
                            share.addParticipant(participant)
                        }
                        
                        // save the record and the share
                        let operation = CKModifyRecordsOperation(recordsToSave: [competitionRecord.record, share],
                                                                 recordIDsToDelete: nil)
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
                                handler(.failure(error))
                                return
                            }
                            guard let savedShare = savedShare, let url = savedShare.url else {
                                handler(.failure(CompetitionsControllerError.unknownError))
                                return
                            }
                            
                            self.inviteFriendsToCompetition(friends, inviteURL: url) { result in
                                switch result {
                                case .success:
                                    handler(.success(()))
                                case .failure(let error):
                                    handler(.failure(error))
                                }
                            }
                        }
                        
                        self.container.privateCloudDatabase.add(operation)
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Fetches pending invitations.
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    ///
    /// Internally, this queries the public database for `InvitationRecord`s matching the users record ID. It is appropriate to store these URLs in the public database as they will only work for the recipient of the invitation.
    func fetchPendingInvitations(then handler: @escaping (Result<[InvitationRecord], Error>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let recordID = recordID else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            
            // find invitations in the public database matching the users record id
            let operation = CKQueryOperation(query: CKQuery(recordType: InvitationRecord.type,
                                                            predicate: NSPredicate(format: "inviteeID == %@",
                                                                                   recordID.recordName)))
            operation.qualityOfService = .userInitiated
            var invitationRecords = [InvitationRecord]()
            
            operation.recordFetchedBlock = { record in
                invitationRecords.append(InvitationRecord(record: record))
            }
            
            operation.queryCompletionBlock = { _, error in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                if invitationRecords.count == 0 {
                    handler(.success([]))
                    return
                }
                handler(.success(invitationRecords))
            }
            
            self.container.publicCloudDatabase.add(operation)
        }
    }
    
    /// Accpets a competition invitation.
    /// - Parameters:
    ///   - invitation: The invitation to accept.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    ///
    /// Internally, this accepts both share URLs present in the invitation (the `CompetitionRecord` share and the `ScoreURLHolder` share), and modifies the `ScoreURLHolder` to contain the share url for the users score infomation.
    func acceptInvitation(_ invitation: InvitationRecord, then handler: @escaping (Result<Void, Error>) -> Void) {
        guard let competitionRecordInviteURLString = invitation.competitionRecordInviteURL,
              let scoreURLHolderInviteURLString = invitation.scoreURLHolderInviteURL,
              let competitionRecordInviteURL = URL(string: competitionRecordInviteURLString),
              let scoreURLHolderInviteURL = URL(string: scoreURLHolderInviteURLString) else {
            handler(.failure(CompetitionsControllerError.missingURL))
            return
        }
        let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [competitionRecordInviteURL,
                                                                               scoreURLHolderInviteURL])
        metadataFetchOperation.qualityOfService = .userInitiated
        
        var shareMetadata = [CKShare.Metadata]()
        var errors = [Error]()
        
        metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            if let error = error {
                errors.append(error)
                return
            }
            guard let metadata = metadata else { return }
            shareMetadata.append(metadata)
        }
        
        metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                handler(.failure(error))
                return
            }
            if !errors.isEmpty {
                handler(.failure(CompetitionsControllerError.multiple(errors)))
            }
            
            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: shareMetadata)
            acceptOperation.qualityOfService = .userInitiated
            
            acceptOperation.acceptSharesCompletionBlock = { error in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                // TODO: Create/get the existing share url for the ScoreRecord and add it to the ScoreURLHolderRecord
                handler(.success(()))
            }
            
            self.container.add(acceptOperation)
        }
        
        container.add(metadataFetchOperation)
    }
    
    /// Fetches all competitions that the user is a participant in, including ones the created.
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    ///
    /// Internally, this queries both the private and the shared database for competitions.
    func fetchCompetitions(then handler: @escaping (Result<[CompetitionRecord], Error>) -> Void) {
        // TODO: Should be optimized with caching
        let dispatchGroup = DispatchGroup()
        
        var competitionRecords = [CompetitionRecord]()
        var errors = [Error]()
        
        let recordFetchHandler = { (result: Result<[CompetitionRecord], Error>) in
            dispatchGroup.leave()
            switch result {
            case .success(let records):
                competitionRecords.append(contentsOf: records)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        dispatchGroup.enter()
        fetchCompetitionsFromDatabaseWithScope(.private, then: recordFetchHandler)
        dispatchGroup.enter()
        fetchCompetitionsFromDatabaseWithScope(.shared, then: recordFetchHandler)
        
        dispatchGroup.notify(queue: .main) {
            if competitionRecords.isEmpty, !errors.isEmpty {
                handler(.failure(CompetitionsControllerError.multiple(errors)))
            } else {
                handler(.success(competitionRecords))
            }
        }
    }
    
    // MARK: Friend Discovery (should be moved out of this class)
    
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
                handler(.failure(CompetitionsControllerError.unknownError))
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
                        handler(.failure(CompetitionsControllerError.unknownError))
                        return
                    }
                    
                    let operation = CKFetchRecordsOperation(recordIDs: identities.compactMap { $0.userRecordID })
                    operation.qualityOfService = .userInitiated
                    operation.fetchRecordsCompletionBlock = { ckRecords, error in
                        if let error = error {
                            handler(.failure(error))
                            return
                        }
                        guard let ckRecords = ckRecords else {
                            handler(.failure(CompetitionsControllerError.unknownError))
                            return
                        }
                        let records = ckRecords
                            .map { UserRecord(record: $0.value) }
                        
                        let friends = records
                            .map {
                                return Friend(name: $0.nickname ?? "",
                                              profilePicture: URL(string: $0.profilePictureURL ?? ""),
                                              recordID: $0.record.recordID)
                            }
                        
                        handler(.success(friends))
                    }
                    
                    container.sharedCloudDatabase.add(operation)
                }
            } else {
                handler(.failure(CompetitionsControllerError.insufficientPermissions))
            }
        }
    }
    
    // MARK: Helper Methods
    
    /// Utility method to create a zone with a randomised identifier.
    private func createZone(then handler: @escaping (Result<CKRecordZone, Error>) -> Void) {
        let zone = CKRecordZone(zoneName: UUID().uuidString)
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        zoneOperation.qualityOfService = .userInitiated
        
        zoneOperation.modifyRecordZonesCompletionBlock = { recordZones, _, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let zone = recordZones?.first else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            
            handler(.success(zone))
        }
        
        container.privateCloudDatabase.add(zoneOperation)
    }
    
    /// Invites friends to a competition with a designated `inviteURL`. The share that the `inviteURL` corresponds to must already have the friend as a participant.
    ///
    /// This creates a CKShare for each invitee that points to a new `ScoreURLHolderRecord`. The invitee can edit this when the accept their invite to contain a share URL that links to their personal `ScoreRecord`.
    private func inviteFriendsToCompetition(_ friends: [Friend],
                                            inviteURL: URL,
                                            then handler: @escaping (Result<Void, Error>) -> Void) {
        fetchShareParticipantsFrom(friends: friends) { result in
            switch result {
            case .success(let participantsAndFriends):
                var urlHolders = [ScoreURLHolderRecord]()
                var shares = [CKShare]()
                var shareForFriend = [Friend: CKShare]()
                
                for (participant, friend) in participantsAndFriends {
                    let urlHolder = ScoreURLHolderRecord()
                    urlHolder.isSet = false
                    urlHolders.append(urlHolder)
                    
                    let publicShare = CKShare(rootRecord: urlHolder.record)
                    publicShare.publicPermission = .none
                    
                    participant.permission = .readWrite
                    publicShare.addParticipant(participant)
                    
                    shares.append(publicShare)
                    
                    shareForFriend[friend] = publicShare
                }
                
                var recordsToSave = urlHolders.map { $0.record }
                recordsToSave.append(contentsOf: shares)
                
                let saveInvitesOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave,
                                                                    recordIDsToDelete: nil)
                saveInvitesOperation.qualityOfService = .userInitiated
                
                var errors = [Error]()
                
                saveInvitesOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        errors.append(error)
                    }
                }
                
                saveInvitesOperation.completionBlock = {
                    if !errors.isEmpty {
                        handler(.failure(CompetitionsControllerError.multiple(errors)))
                        return
                    }
                    var inviteRecords = [InvitationRecord]()
                    
                    for friend in friends {
                        guard let share = shareForFriend[friend], let shareURL = share.url else { continue }
                        let inviteRecord = InvitationRecord()
                        inviteRecord.competitionRecordInviteURL = "\(inviteURL)"
                        inviteRecord.scoreURLHolderInviteURL = "\(shareURL)"
                        inviteRecord.inviteeID = friend.recordID.recordName
                        
                        inviteRecords.append(inviteRecord)
                    }
                    
                    handler(.success(()))
                }
                
                self.container.publicCloudDatabase.add(saveInvitesOperation)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Fetches share participants that can be used with a CKShare.
    private func fetchShareParticipantsFrom(friends: [Friend],
                                            then handler: @escaping (Result<[(CKShare.Participant, Friend)], Error>) -> Void) {
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
    
    private func fetchCompetitionsFromDatabaseWithScope(_ scope: CKDatabase.Scope,
                                                        then handler:
                                                            @escaping (Result<[CompetitionRecord], Error>) -> Void) {
        let database = container.database(with: scope)
        let fetchZonesOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        
        fetchZonesOperation.qualityOfService = .userInitiated
        fetchZonesOperation.fetchRecordZonesCompletionBlock = { recordZones, error in
            print(scope)
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let zones = recordZones?.map({ $0.value }) else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            guard !zones.isEmpty else {
                handler(.success([]))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            var competitions = [CompetitionRecord]()
            var errors = [Error]()
            
            for zone in zones {
                dispatchGroup.enter()
                let fetchRecordOperation = CKQueryOperation(query: CKQuery(recordType: CompetitionRecord.type,
                                                                           predicate: NSPredicate(value: true)))
                fetchRecordOperation.qualityOfService = .userInitiated
                fetchRecordOperation.zoneID = zone.zoneID
                fetchRecordOperation.recordFetchedBlock = { record in
                    competitions.append(CompetitionRecord(record: record))
                }
                fetchRecordOperation.queryCompletionBlock = { _, error in
                    defer { dispatchGroup.leave() }
                    if let error = error {
                        errors.append(error)
                        return
                    }
                }
                
                database.add(fetchRecordOperation)
            }
            
            dispatchGroup.notify(queue: .main) {
                if !errors.isEmpty, competitions.isEmpty {
                    handler(.failure(CompetitionsControllerError.multiple(errors)))
                    return
                }
                handler(.success(competitions))
            }
        }
        
        database.add(fetchZonesOperation)
    }
    
    /// Creates a score record for the user. Should only be called if the score record doesn't already exist.
    private func createScoreRecord(then handler: @escaping (Result<Void, Error>) -> Void) {
        let scoreRecord = ScoreRecord()
        
        let share = CKShare(rootRecord: scoreRecord.record)
        share.publicPermission = .readOnly
        
        // TODO: Save record and persist it to the private user profile
    }
    
    // MARK: Competition Controller Error
    
    enum CompetitionsControllerError: Error {
        case unknownError
        case insufficientPermissions
        case missingURL
        case multiple([Error])
    }
    
}
