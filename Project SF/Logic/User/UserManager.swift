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
    func fetchPrivateUserRecord(then handler: @escaping (Result<UserRecord, UserManagerError>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                handler(.failure(.other(error)))
                return
            }
            
            guard let recordID = recordID else {
                handler(.failure(UserManagerError.missingID))
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
        then handler: @escaping (Result<Void, UserManagerError>) -> Void
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
    
    func fetchPublicUserRecord(then handler: @escaping (Result<PublicUserRecord, UserManagerError>) -> Void) {
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
        then handler: @escaping (Result<PublicUserRecord, UserManagerError>) -> Void
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
        then handler: @escaping (Result<Void, UserManagerError>) -> Void
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
    
    func fetchSharedUserRecord(then handler: @escaping (Result<SharedUserRecord, UserManagerError>) -> Void) {
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
        then handler: @escaping (Result<SharedUserRecord, UserManagerError>) -> Void
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
    
    /// Save shared user with CloudKitStore.shared.saveRecord()
    
    enum UserManagerError: Error {
        case other(Error)
        case unknownError
        case missingRecord
        case missingID
    }
}
