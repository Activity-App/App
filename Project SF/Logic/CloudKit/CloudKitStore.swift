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
                      scope: CKDatabase.Scope,
                      then handler: @escaping (Result<[CKRecord], CloudKitStoreError>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInitiated

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
                                          scope: CKDatabase.Scope,
                                          then handler: @escaping (Result<[RecordType], CloudKitStoreError>) -> Void) {
        fetchRecords(with: record.type, predicate: predicate, scope: scope) { result in
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
    
    /// Asynchronously fetches the user record from the CloudKit database
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchUserRecord(then handler: @escaping (Result<UserRecord, CloudKitStoreError>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                handler(.failure(.other(error)))
                return
            }
            
            guard let recordID = recordID else {
                handler(.failure(CloudKitStoreError.missingID))
                return
            }
            
            // TODO: Determine whether or not this could be a memory leak
            
            self.fetchRecord(with: recordID, scope: .private) { result in
                switch result {
                case .success(let record):
                    handler(.success(UserRecord(record: record)))
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }
    
    // MARK: Saving
    
    /// Asynchronously saves a single record to the CloudKit database.
    /// - Parameters:
    ///   - record: The record to save.
    ///   - scope: The database scope.
    ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
    ///   - handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func saveRecord(_ record: CKRecord,
                    scope: CKDatabase.Scope,
                    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
                    then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        let database = container.database(with: scope)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = savePolicy
        operation.qualityOfService = .userInitiated
        operation.perRecordCompletionBlock = { _, error in
            if let error = error {
                handler(.failure(.other(error)))
                return
            }
            handler(.success(()))
        }
        
        database.add(operation)
     }
    
    func saveUserRecord(_ record: UserRecord,
                        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
                        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        saveRecord(record.record, scope: .private, savePolicy: savePolicy) { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(error))
            }
        }
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

    // MARK: - CloudKitStoreError

    enum CloudKitStoreError: Error {
        case other(Error)
        case missingRecord
        case missingID
    }

}
