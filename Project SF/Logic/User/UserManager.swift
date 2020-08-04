//
//  UserManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 31/7/20.
//

import CloudKit

class UserManager {
    
    static let shared = UserManager()
    
    private let container: CKContainer = .appDefault
    private let cloudKitStore = CloudKitStore.shared
    private let userDefaults = UserDefaults.standard
    
    private init() { }
    
    // MARK: Private User.
    
    /// Asynchronously fetches the user record from the CloudKit database
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchPrivateUserRecord(then handler: @escaping (Result<UserRecord, CloudKitStoreError>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                handler(.failure(.other(error)))
                return
            }
            
            guard let recordID = recordID else {
                handler(.failure(CloudKitStoreError.missingID))
                return
            }
            
            self.cloudKitStore.fetchRecord(with: recordID, scope: .private) { result in
                switch result {
                case .success(let record):
                    handler(.success(UserRecord(record: record)))
                case .failure(let error):
                    handler(.failure(.other(error)))
                }
            }
        }
    }
    
    func savePrivateUserRecord(
        _ record: UserRecord,
        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        cloudKitStore.saveRecord(record.record, scope: .private, savePolicy: savePolicy) { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
    
    // MARK: Public User.
    
    func setupPublicUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchPublicUserRecord {
    }
    
    private func createPublicUser(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchPrivateUserRecord { result in
            switch result {
            case .success(let privateUserRecord):
                /// Create a new randomized record name and save it to the private record.
                let recordName = UUID().uuidString
                
                let newRecord = PublicUserRecord(recordID: CKRecord.ID(recordName: recordName))
                newRecord.privateUserRecordName = privateUserRecord.record.recordID.recordName
                
                self.cloudKitStore.saveRecord(newRecord.record, scope: .public) { result in
                    switch result {
                    case .success:
                        /// Update the private user record with the record name of the public user record.
                        privateUserRecord.publicUserRecordName = recordName
                        self.savePrivateUserRecord(privateUserRecord) { result in
                            switch result {
                            case .success:
                                handler(.success(()))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        handler(.failure(.other(error)))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func fetchPublicUserRecord(then handler: @escaping (Result<PublicUserRecord, CloudKitStoreError>) -> Void) {
        if let publicUserRecordName = userDefaults.string(forKey: "publicUserRecordName") {
            fetchPublicUserRecordWith(recordName: publicUserRecordName) { result in
                switch result {
                case .success(let publicUserRecord):
                    handler(.success(publicUserRecord))
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        } else {
            fetchPrivateUserRecord { result in
                switch result {
                case .success(let privateUserRecord):
                    guard let publicUserRecordName = privateUserRecord.publicUserRecordName else {
                        handler(.failure(.missingID))
                        return
                    }
                    self.fetchPublicUserRecordWith(recordName: publicUserRecordName) { result in
                        switch result {
                        case .success(let publicUserRecord):
                            handler(.success(publicUserRecord))
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }
    
    private func fetchPublicUserRecordWith(
        recordName: String,
        then handler: @escaping (Result<PublicUserRecord, CloudKitStoreError>) -> Void
    ) {
        let publicUserRecordID = CKRecord.ID(recordName: recordName)
        
        cloudKitStore.fetchRecord(with: publicUserRecordID, scope: .public) { result in
            switch result {
            case .success(let record):
                handler(.success(PublicUserRecord(record: record)))
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
    
    func savePublicUserRecord(
        _ record: PublicUserRecord,
        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        cloudKitStore.saveRecord(record.record, scope: .public, savePolicy: savePolicy) { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
    
    // MARK: Shared User
    
    func fetchSharedUserRecord(then handler: @escaping (Result<SharedUserRecord, CloudKitStoreError>) -> Void) {
        if let sharedUserRecordName = userDefaults.string(forKey: "sharedUserRecordName") {
            fetchSharedUserRecordWith(recordName: sharedUserRecordName) { result in
                switch result {
                case .success(let sharedUserRecord):
                    handler(.success(sharedUserRecord))
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        } else {
            fetchPrivateUserRecord { result in
                switch result {
                case .success(let privateUserRecord):
                    guard let sharedUserRecordName = privateUserRecord.sharedUserRecordName else {
                        handler(.failure(.missingID))
                        return
                    }
                    self.fetchSharedUserRecordWith(recordName: sharedUserRecordName) { result in
                        switch result {
                        case .success(let publicUserRecord):
                            handler(.success(publicUserRecord))
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }
    
    private func fetchSharedUserRecordWith(
        recordName: String,
        then handler: @escaping (Result<SharedUserRecord, CloudKitStoreError>) -> Void
    ) {
        let zone = CKRecordZone.ID(zoneName: "SharedToFriendsDataZone")
        let sharedUserRecordID = CKRecord.ID(recordName: recordName, zoneID: zone)
        
        cloudKitStore.fetchRecord(with: sharedUserRecordID, scope: .private) { result in
            switch result {
            case .success(let record):
                handler(.success(SharedUserRecord(record: record)))
            case .failure(let error):
                handler(.failure(.other(error)))
            }
        }
    }
}
