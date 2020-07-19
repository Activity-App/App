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
// TODO: Add proper error handling with retrying
// TODO: Make sure all operations have their quality of service set to .userInitiated
// swiftlint:disable type_body_length
// NOTE: SwiftLint disable is temporary
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
    /// Internally, this creates a `CompetitionRecord` which is shared to all friend participants (with read only access). The `CompetitionRecord` contains all the competition metadata and a list of share urls pointing to `ScoreURLHolderRecord`s which, if the participant has joined the competition, contain a share url that will grant access to the participants score infomation.
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
                            
                            self.inviteFriendsToCompetition(friends, inviteURL: url, zoneID: zone.zoneID) { result in
                                switch result {
                                case .success(let scoreURLHolderShareURLs):
                                    competitionRecord.scoreURLHolderShareURLs = scoreURLHolderShareURLs.map { "\($0)" }
                                    
                                    let finalSaveOperation = CKModifyRecordsOperation(recordsToSave: [competitionRecord.record],
                                                                                      recordIDsToDelete: nil)
                                    finalSaveOperation.qualityOfService = .userInitiated
                                    
                                    finalSaveOperation.modifyRecordsCompletionBlock = { _, _, error in
                                        if let error = error {
                                            handler(.failure(error))
                                            return
                                        }
                                        
                                        handler(.success(()))
                                    }
                                    
                                    self.container.privateCloudDatabase.add(finalSaveOperation)
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
            guard let scoreURLHolderShareMetadata = shareMetadata.first(where: { $0.share.url == scoreURLHolderInviteURL }) else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            
            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: shareMetadata)
            acceptOperation.qualityOfService = .userInitiated
            
            acceptOperation.acceptSharesCompletionBlock = { error in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                // TODO: Create/get the existing share url for the ScoreRecord and add it to the ScoreURLHolderRecord
                self.fetchScoreRecordInfomation { result in
                    switch result {
                    case .success(let url):
                        let fetchURLHolderOperation = CKFetchRecordsOperation(recordIDs: [scoreURLHolderShareMetadata.rootRecordID])
                        fetchURLHolderOperation.qualityOfService = .userInitiated
                        fetchURLHolderOperation.fetchRecordsCompletionBlock = { records, error in
                            if let error = error {
                                handler(.failure(error))
                                return
                            }
                            guard let recordRaw = records?.first?.value else {
                                handler(.failure(CompetitionsControllerError.unknownError))
                                return
                            }
                            let record = ScoreURLHolderRecord(record: recordRaw)
                            record.isSet = true
                            record.url = "\(url)"
                            
                            let saveRecordOperation = CKModifyRecordsOperation(recordsToSave: [record.record],
                                                                               recordIDsToDelete: nil)
                            saveRecordOperation.qualityOfService = .userInitiated
                            saveRecordOperation.modifyRecordsCompletionBlock = { _, _, error in
                                if let error = error {
                                    handler(.failure(error))
                                    return
                                }
                                
                                handler(.success(()))
                            }
                            
                            self.container.sharedCloudDatabase.add(saveRecordOperation)
                        }
                        
                        self.container.sharedCloudDatabase.add(fetchURLHolderOperation)
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
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
    
    func fetchScoreRecordsFor(_ competition: CompetitionRecord,
                              then handler: @escaping (Result<[ScoreRecord], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var personalScoreRecordResult: Result<ScoreRecord, Error>?
        var otherScoreRecordsResult: Result<[ScoreRecord], Error>?
        
        dispatchGroup.enter()
        fetchPersonalScoreRecord { result in
            personalScoreRecordResult = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchExternalScoreRecordsFor(competition) { result in
            otherScoreRecordsResult = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            guard let personalScoreRecordResult = personalScoreRecordResult,
                  let otherScoreRecordsResult = otherScoreRecordsResult else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            
            var records = [ScoreRecord]()
            switch personalScoreRecordResult {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                handler(.failure(error))
                return
            }
            
            switch otherScoreRecordsResult {
            case .success(let scoreRecords):
                records.append(contentsOf: scoreRecords)
            case .failure(let error):
                handler(.failure(error))
                return
            }
            
            handler(.success(records))
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
                                            zoneID: CKRecordZone.ID,
                                            then handler: @escaping (Result<[URL], Error>) -> Void) {
        fetchShareParticipantsFrom(friends: friends) { result in
            switch result {
            case .success(let participantsAndFriends):
                var urlHolders = [ScoreURLHolderRecord]()
                var shares = [CKShare]()
                var friendToShare = [Friend: CKShare]()
                
                for (participant, friend) in participantsAndFriends {
                    let urlHolder = ScoreURLHolderRecord(recordID: CKRecord.ID(zoneID: zoneID))
                    urlHolder.isSet = false
                    urlHolders.append(urlHolder)
                    
                    let share = CKShare(rootRecord: urlHolder.record)
                    share.publicPermission = .none
                    
                    for (participantToAdd, _) in participantsAndFriends {
                        if participant == participantToAdd {
                            participant.permission = .readWrite
                        } else {
                            participant.permission = .readOnly
                        }
                        share.addParticipant(participant)
                    }
                    
                    shares.append(share)
                    
                    friendToShare[friend] = share
                }
                
                var recordsToSave = urlHolders.map { $0.record }
                recordsToSave.append(contentsOf: shares)
                
                let saveScoreURLHoldersOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave,
                                                                    recordIDsToDelete: nil)
                saveScoreURLHoldersOperation.qualityOfService = .userInitiated
                
                var errors = [Error]()
                
                saveScoreURLHoldersOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        errors.append(error)
                    }
                }
                
                saveScoreURLHoldersOperation.completionBlock = {
                    if !errors.isEmpty {
                        handler(.failure(CompetitionsControllerError.multiple(errors)))
                        return
                    }
                    var inviteRecords = [InvitationRecord]()
                    
                    for friend in friends {
                        guard let share = friendToShare[friend], let shareURL = share.url else { continue }
                        let inviteRecord = InvitationRecord()
                        inviteRecord.competitionRecordInviteURL = "\(inviteURL)"
                        inviteRecord.scoreURLHolderInviteURL = "\(shareURL)"
                        inviteRecord.inviteeID = friend.recordID.recordName
                        
                        inviteRecords.append(inviteRecord)
                    }
                    
                    let saveInvitationsOperations = CKModifyRecordsOperation(recordsToSave: inviteRecords.map({ $0.record }),
                                                                             recordIDsToDelete: nil)
                    
                    saveInvitationsOperations.modifyRecordsCompletionBlock = { _, _, error in
                        if let error = error {
                            handler(.failure(error))
                            return
                        }
                        
                        handler(.success(shares.compactMap { $0.url }))
                    }
                    
                    self.container.publicCloudDatabase.add(saveInvitationsOperations)
                }
                
                self.container.privateCloudDatabase.add(saveScoreURLHoldersOperation)
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
    
    private func fetchScoreRecordInfomation(then handler: @escaping (Result<(shareURL: URL, recordID: CKRecord.ID), Error>) -> Void) {
        // TODO: Add caching
        
        let fetchUserRecordOperation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
        fetchUserRecordOperation.fetchRecordsCompletionBlock = { records, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let userRecordRaw = records?.first?.value else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            let userRecord = UserRecord(record: userRecordRaw)
            
            if let shareURLString = userRecord.scoreRecordPublicShareURL,
               let shareURL = URL(string: shareURLString),
               let scoreRecordZoneName = userRecord.scoreRecordZoneName,
               let scoreRecordRecordName = userRecord.scoreRecordRecordName {
                let recordID = CKRecord.ID(recordName: scoreRecordRecordName,
                                           zoneID: CKRecordZone.ID(zoneName: scoreRecordZoneName))
                handler(.success((shareURL, recordID)))
            } else {
                self.createScoreRecord { result in
                    switch result {
                    case .success((let shareURL, let recordID)):
                        handler(.success((shareURL, recordID)))
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            }
        }
        
        container.privateCloudDatabase.add(fetchUserRecordOperation)
    }
    
    /// Creates a score record for the user. Should only be called if the score record doesn't already exist.
    private func createScoreRecord(then handler: @escaping (Result<(shareURL: URL, recordID: CKRecord.ID), Error>) -> Void) {
        self.createZone { result in
            switch result {
            case .success(let zone):
                
                let scoreRecord = ScoreRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                
                let share = CKShare(rootRecord: scoreRecord.record)
                share.publicPermission = .readOnly
                
                let recordsToSave = [scoreRecord.record, share]
                let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave,
                                                             recordIDsToDelete: nil)
                
                saveOperation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let shareURL = share.url else {
                        handler(.failure(CompetitionsControllerError.unknownError))
                        return
                    }
                    
                    let userRecordFetchOperation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
                    userRecordFetchOperation.fetchRecordsCompletionBlock = { records, error in
                        if let error = error {
                            handler(.failure(error))
                            return
                        }
                        guard let userRecordRaw = records?.first?.value else {
                            handler(.failure(CompetitionsControllerError.unknownError))
                            return
                        }
                        
                        let userRecord = UserRecord(record: userRecordRaw)
                        
                        userRecord.scoreRecordZoneName = scoreRecord.record.recordID.zoneID.zoneName
                        userRecord.scoreRecordRecordName = scoreRecord.record.recordID.recordName
                        userRecord.scoreRecordPublicShareURL = "\(shareURL)"
                        
                        let userRecordSaveOperation = CKModifyRecordsOperation(recordsToSave: [userRecord.record],
                                                                               recordIDsToDelete: nil)
                        userRecordSaveOperation.modifyRecordsCompletionBlock = { _, _, error in
                            if let error = error {
                                handler(.failure(error))
                                return
                            }
                            
                            handler(.success((shareURL, scoreRecord.record.recordID)))
                        }
                        
                        self.container.privateCloudDatabase.add(userRecordSaveOperation)
                    }
                    
                    self.container.privateCloudDatabase.add(userRecordFetchOperation)
                }
                
                self.container.privateCloudDatabase.add(saveOperation)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    private func fetchExternalScoreRecordsFor(_ competition: CompetitionRecord,
                                              then handler: @escaping (Result<[ScoreRecord], Error>) -> Void) {
        // TODO: Add caching
        
        guard let scoreURLHolderShareURLStrings = competition.scoreURLHolderShareURLs else {
            handler(.success([]))
            return
        }
        let urls = scoreURLHolderShareURLStrings.compactMap { URL(string: $0) }
        
        let shareMetadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: urls)
        shareMetadataFetchOperation.qualityOfService = .userInitiated
        
        var metadatas = [CKShare.Metadata]()
        var errors = [Error]()
        
        shareMetadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            if let error = error {
                errors.append(error)
                return
            }
            if let metadata = metadata {
                metadatas.append(metadata)
            }
        }
        shareMetadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                handler(.failure(error))
                return
            }
            if metadatas.isEmpty, !errors.isEmpty {
                handler(.failure(CompetitionsControllerError.multiple(errors)))
                return
            }
            
            var sharesNeedingAcceptance = [CKShare.Metadata]()
            
            for metadata in metadatas where metadata.participantStatus == .pending {
                sharesNeedingAcceptance.append(metadata)
            }
            
            func handleAllSharesSuccessfullyAccepted() {
                let competitionAuthorID = competition.record.creatorUserRecordID
                
                let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: metadatas.map { $0.rootRecordID })
                fetchRecordsOperation.fetchRecordsCompletionBlock = { records, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let records = records?.map({ $0.value }) else {
                        handler(.failure(CompetitionsControllerError.unknownError))
                        return
                    }
                    
                    let scoreRecords = records
                        // prevent competition creator from faking ScoreRecords
                        .filter { $0.creatorUserRecordID == competitionAuthorID }
                        .map { ScoreRecord(record: $0) }
                    
                    handler(.success(scoreRecords))
                }
                
                self.container.sharedCloudDatabase.add(fetchRecordsOperation)
            }
            
            if sharesNeedingAcceptance.isEmpty {
                handleAllSharesSuccessfullyAccepted()
            } else {
                let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: sharesNeedingAcceptance)
                acceptSharesOperation.acceptSharesCompletionBlock = { error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    handleAllSharesSuccessfullyAccepted()
                }
                
                self.container.add(acceptSharesOperation)
            }
        }
        
        container.add(shareMetadataFetchOperation)
    }
    
    private func fetchPersonalScoreRecord(then handler: @escaping (Result<ScoreRecord, Error>) -> Void) {
        fetchScoreRecordInfomation { result in
            switch result {
            case .success((_, let recordID)):
                let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
                fetchOperation.qualityOfService = .userInitiated
                
                fetchOperation.fetchRecordsCompletionBlock = { records, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let record = records?.first?.value else {
                        handler(.failure(CompetitionsControllerError.unknownError))
                        return
                    }
                    
                    let scoreRecord = ScoreRecord(record: record)
                    
                    handler(.success(scoreRecord))
                }
                
                self.container.privateCloudDatabase.add(fetchOperation)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    // MARK: Competition Controller Error
    
    enum CompetitionsControllerError: Error {
        case unknownError
        case insufficientPermissions
        case missingURL
        case multiple([Error])
    }
    
}
