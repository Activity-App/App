//
//  CloudKitStore.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import Foundation
import CloudKit

class CloudKitStore {

    // MARK: Static Properties

    static let shared = CloudKitStore(container: .appDefault)

    private static let queue = DispatchQueue(label: "com.wwdc.Project-SF.cloudkitqueue")

    // MARK: Properties

    private let container: CKContainer

    // MARK: Init

    init(container: CKContainer) {
        self.container = container
    }

    // MARK: Fetching
    
    /// Asynchronously fetches records from the CloudKit database.
    /// Current Limitation: Doesn't handle paging correctly
    /// - Parameters:
    ///   - recordType: The type of record to fetch.
    ///   - predicate: Condition for records to be fetched.
    ///   - scope: The database scope.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchRecords(with recordType: CKRecord.RecordType,
                      predicate: NSPredicate = NSPredicate(value: true),
                      zone: CKRecordZone.ID,
                      scope: CKDatabase.Scope,
                      then handler: @escaping (Result<[CKRecord], CloudKitStoreError>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInitiated
        queryOperation.zoneID = zone

        var records = [CKRecord]()

        queryOperation.recordFetchedBlock = { record in
            Self.queue.sync {
                records.append(record)
            }
        }

        queryOperation.queryCompletionBlock = { cursor, error in
            Self.queue.sync {
                // TODO: Need to properly handle paging
                if let error = error {
                    if let ckError = error as? CKError {
                        handler(.failure(.ckError(ckError)))
                        return
                    }
                    handler(.failure(.other(error)))
                    return
                }

                handler(.success(records))
            }
        }

        let database = container.database(with: scope)
        database.add(queryOperation)
    }
    
    /// Asynchronously fetches records from the CloudKit database
    /// - Parameters:
    ///   - record: The type of the record to fetch.
    ///   - predicate: Condition for records to be fetched.
    ///   - scope: The database scope.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchRecords<RecordType: Record>(with record: RecordType.Type,
                                          predicate: NSPredicate = NSPredicate(value: true),
                                          zone: CKRecordZone.ID = .default,
                                          scope: CKDatabase.Scope,
                                          then handler: @escaping (Result<[RecordType], CloudKitStoreError>) -> Void) {
        fetchRecords(with: record.type, predicate: predicate, zone: zone, scope: scope) { result in
            switch result {
            case .success(let records):
                let records = records.map { RecordType.init(record: $0) }
                
                handler(.success(records))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Asynchronously fetches a single record from the CloudKit database.
    /// - Parameters:
    ///   - recordID: The ID of the record you want to fetch.
    ///   - scope: The database scope
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchRecord(with recordID: CKRecord.ID,
                     scope: CKDatabase.Scope,
                     then handler: @escaping (Result<CKRecord, CloudKitStoreError>) -> Void) {
        let database = container.database(with: scope)

        database.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            guard let record = record else {
                handler(.failure(CloudKitStoreError.missingRecord))
                return
            }

            handler(.success(record))
        }
    }
    
    func fetchShare(with shareURL: URL, then handler: @escaping (Result<CKShare, CloudKitStoreError>) -> Void) {
        /// Fetch the share metadata from the friend share URL.
        let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: [shareURL])
        metadataFetchOperation.qualityOfService = .userInitiated
        
        var shareMetadata: [CKShare.Metadata] = []
        
        metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            guard let metadata = metadata else { handler(.failure(.unknownError)); return }
            shareMetadata.append(metadata)
        }
        
        metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            
            /// Get the associated share from the share metadata.
            guard let shareURLMetadata = shareMetadata.first(
                    where: { $0.share.url == shareURL }
            ) else {
                handler(.failure(.unknownError))
                return
            }
            let share = shareURLMetadata.share
            handler(.success(share))
        }
        
        container.add(metadataFetchOperation)
    }
    
    // MARK: Saving
    
    /// Asynchronously saves multiple records to the CloudKit database.
    /// - Parameters:
    ///   - records: The records to save.
    ///   - scope: The database scope.
    ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func saveRecords(_ records: [CKRecord],
                    scope: CKDatabase.Scope,
                    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
                    then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        let database = container.database(with: scope)
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = savePolicy
        operation.qualityOfService = .userInitiated
        
        operation.perRecordCompletionBlock = { _, error in
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
        
        database.add(operation)
    }
    
    func saveRecord(_ record: CKRecord,
                    scope: CKDatabase.Scope,
                    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
                    then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        saveRecords([record], scope: scope, then: handler)
    }
    
    /// Utility method to create a zone with a randomised identifier.
    func createZone(
        named zoneName: String = UUID().uuidString,
        then handler: @escaping (Result<CKRecordZone, CloudKitStoreError>) -> Void
    ) {
        let zone = CKRecordZone(zoneName: zoneName)
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        zoneOperation.qualityOfService = .userInitiated
        
        zoneOperation.modifyRecordZonesCompletionBlock = { recordZones, _, error in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            guard let zone = recordZones?.first else {
                handler(.failure(.unknownError))
                return
            }
            
            handler(.success(zone))
        }
        
        container.privateCloudDatabase.add(zoneOperation)
    }
    
    // MARK: Deleting
    
    /// Asynchronously deletes a single record to the CloudKit database, with a low priority.
    /// - Parameters:
    ///   - recordID: The ID of the record you want to delete.
    ///   - scope: The database scope.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func deleteRecord(with recordID: CKRecord.ID,
                      scope: CKDatabase.Scope,
                      then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        let database = container.database(with: scope)

        database.delete(withRecordID: recordID) { _, error in
            if let error = error {
                handler(.failure(.other(error)))
                return
            }
            handler(.success(()))
        }
    }
    
    // MARK: Utilities
    
    /// Fetches share participants that can be used with a CKShare.
    func fetchShareParticipantsFromRecordNames(
        users: [String],
        then completion: @escaping (Result<[CKShare.Participant], CloudKitStoreError>) -> Void
    ) {
        let lookupInfo = users.map { CKUserIdentity.LookupInfo(userRecordID: CKRecord.ID(recordName: $0)) }
        let fetchParticipantsOperation = CKFetchShareParticipantsOperation(
            userIdentityLookupInfos: lookupInfo
        )
        fetchParticipantsOperation.qualityOfService = .userInitiated
        
        var participants = [CKShare.Participant]()
        
        fetchParticipantsOperation.shareParticipantFetchedBlock = { participant in
            participants.append(participant)
        }
        
        fetchParticipantsOperation.fetchShareParticipantsCompletionBlock = { error in
            if let error = error, participants.count == 0 {
                if let ckError = error as? CKError {
                    completion(.failure(.ckError(ckError)))
                    return
                }
                completion(.failure(.other(error)))
                return
            }
            let returnValue: [CKShare.Participant] = participants
            completion(.success(returnValue))
        }
        self.container.add(fetchParticipantsOperation)
    }
}

// MARK: - CloudKitStoreError

enum CloudKitStoreError: Error {
    case other(Error)
    case ckError(CKError)
    case unknownError
    case missingRecord
    case missingID
}
