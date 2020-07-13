//
//  CompetitionsController.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

class CompetitionsController {
    
    // MARK: Properties
    
    private let container: CKContainer
    
    // MARK: Init
    
    init(container: CKContainer = .appDefault) {
        self.container = container
    }
    
    // MARK: Methods
    
    func createCompetition(type: CompetitionRecord.CompetitionType,
                           endDate: Date,
                           friends: [Friend],
                           then handler: @escaping (Result<Bool, Error>) -> Void) {
        /*let zone = CKRecordZone(zoneName: UUID().uuidString)
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
            }*/
            
        let competitionRecord = CompetitionRecord()
        competitionRecord.type = type
        competitionRecord.startDate = Date()
        competitionRecord.endDate = endDate
        
        let share = CKShare(rootRecord: competitionRecord.record)
        share.publicPermission = .none
        share[CKShare.SystemFieldKey.title] = "Competition"
        
        let friendLookupInfomation = friends.map { CKUserIdentity.LookupInfo(userRecordID: $0.recordID) }
        let participantLookupOperation = CKFetchShareParticipantsOperation(userIdentityLookupInfos:
                                                                            friendLookupInfomation)
        participantLookupOperation.qualityOfService = .userInitiated
        
        var participants = [CKShare.Participant]()
        
        participantLookupOperation.shareParticipantFetchedBlock = { participant in
            participants.append(participant)
        }
        
        participantLookupOperation.fetchShareParticipantsCompletionBlock = { [container] error in
            if let error = error, participants.count == 0 {
                handler(.failure(error))
                return
            }
            
            let operation = CKModifyRecordsOperation(recordsToSave: [competitionRecord.record, share],
                                                     recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            var savedShare: CKShare?
            var savedCompetitionRecord: CKRecord?
            
            operation.perRecordCompletionBlock = { record, error in
                if let record = record as? CKShare {
                    savedShare = record
                } else {
                    savedCompetitionRecord = record
                }
            }
            
            operation.completionBlock = {
                guard let savedShare = savedShare, let url = savedShare.url else {
                    handler(.failure(CompetitionsControllerError.unknownError))
                    return
                }
                
                
            }
            
            container.privateCloudDatabase.add(operation)
        }
        
        participantLookupOperation.start()
        /*}
        
        container.privateCloudDatabase.add(zoneOperation)*/
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
    
    // MARK: Competition Controller Error
    
    enum CompetitionsControllerError: Error {
        case unknownError
        case insufficientPermissions
    }
    
}
