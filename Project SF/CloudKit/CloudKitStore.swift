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

    static let shared = CloudKitStore(container: CKContainer.default())

    private static let queue = DispatchQueue(label: "com.wwdc.Project-SF.cloudkitqueue")

    // MARK: Properties

    private let container: CKContainer

    // MARK: Init

    init(container: CKContainer) {
        self.container = container
    }

    // MARK: Methods

    func fetchRecords(with recordType: CKRecord.RecordType,
                      predicate: NSPredicate,
                      scope: CKDatabase.Scope,
                      then handler: @escaping (Result<[CKRecord], Error>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

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
                    handler(.failure(error))
                    return
                }

                handler(.success(records))
            }
        }

        let database = container.database(with: scope)
        database.add(queryOperation)
    }

    func fetchRecord(with recordID: CKRecord.ID,
                     scope: CKDatabase.Scope,
                     then handler: @escaping (Result<CKRecord, Error>) -> Void) {
        let database = container.database(with: scope)

        database.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let record = record else {
                handler(.failure(CloudKitStoreError.missingRecord))
                return
            }

            handler(.success(record))
        }
    }

    // MARK: - CloudKitStoreError

    enum CloudKitStoreError: Error {
        case missingRecord
    }

}
