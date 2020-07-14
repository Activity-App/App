//
//  CompetitionsController.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

// TODO: Possibly refactor into multiple controllers
class CompetitionsController {
    
    // MARK: Properties
    
    private let container: CKContainer
    
    // MARK: Init
    
    init(container: CKContainer = .appDefault) {
        self.container = container
    }
    
    // MARK: Competitions
    
    func createCompetition(type: CompetitionRecord.CompetitionType,
                           endDate: Date,
                           friends: [Friend],
                           then handler: @escaping (Result<Void, Error>) -> Void) {
        createZone { result in
            switch result {
            case .success(let zone):
                self.fetchShareParticipantsFrom(friends: friends) { result in
                    switch result {
                    case .success(let participants):
                        let competitionRecord = CompetitionRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                        competitionRecord.type = type
                        competitionRecord.startDate = Date()
                        competitionRecord.endDate = endDate
                        
                        let share = CKShare(rootRecord: competitionRecord.record)
                        share.publicPermission = .none
                        share[CKShare.SystemFieldKey.title] = "Competition"
                        
                        for participant in participants {
                            participant.permission = .readOnly
                            share.addParticipant(participant)
                        }
                        
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
    
    func acceptInvitation(_ invitation: InvitationRecord, then handler: @escaping (Result<Void, Error>) -> Void) {
        guard let urlString = invitation.url, let url = URL(string: urlString) else {
            handler(.failure(CompetitionsControllerError.missingURL))
            return
        }
        let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [url])
        metadataFetchOperation.qualityOfService = .userInitiated
        
        var shareMetadata: CKShare.Metadata?
        
        metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            shareMetadata = metadata
        }
        
        metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let shareMetadata = shareMetadata else {
                handler(.failure(CompetitionsControllerError.unknownError))
                return
            }
            
            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: [shareMetadata])
            acceptOperation.qualityOfService = .userInitiated
            
            acceptOperation.acceptSharesCompletionBlock = { error in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                handler(.success(()))
            }
            
            self.container.add(acceptOperation)
        }
        
        container.add(metadataFetchOperation)
    }
    
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
        fetchCompetitionsFromDatabaseWithScope(.private, then: { (result: Result<[CompetitionRecord], Error>) in
            dispatchGroup.leave()
            switch result {
            case .success(let records):
                competitionRecords.append(contentsOf: records)
            case .failure(let error):
                errors.append(error)
            }
        })
        dispatchGroup.enter()
        fetchCompetitionsFromDatabaseWithScope(.shared, then: { (result: Result<[CompetitionRecord], Error>) in
            dispatchGroup.leave()
            switch result {
            case .success(let records):
                competitionRecords.append(contentsOf: records)
            case .failure(let error):
                errors.append(error)
            }
        })
        
        dispatchGroup.notify(queue: .main) {
            if competitionRecords.isEmpty, !errors.isEmpty {
                handler(.failure(CompetitionsControllerError.multiple(errors)))
            } else {
                handler(.success(competitionRecords))
            }
        }
    }
    
    // MARK: Friend Discovery
    
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
    
    private func inviteFriendsToCompetition(_ friends: [Friend],
                                            inviteURL: URL,
                                            then handler: @escaping (Result<Void, Error>) -> Void) {
        var inviteRecords = [InvitationRecord]()
        
        for friend in friends {
            let inviteRecord = InvitationRecord()
            inviteRecord.url = "\(inviteURL)"
            inviteRecord.inviteeID = friend.recordID.recordName
            
            inviteRecords.append(inviteRecord)
        }
        
        let saveInvitesOperation = CKModifyRecordsOperation(recordsToSave: inviteRecords.map { $0.record },
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
            handler(.success(()))
        }
        
        container.publicCloudDatabase.add(saveInvitesOperation)
    }
    
    private func fetchShareParticipantsFrom(friends: [Friend],
                                            then handler: @escaping (Result<[CKShare.Participant], Error>) -> Void) {
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
            
            handler(.success(participants))
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
    
    // MARK: Competition Controller Error
    
    enum CompetitionsControllerError: Error {
        case unknownError
        case insufficientPermissions
        case missingURL
        case multiple([Error])
    }
    
}
