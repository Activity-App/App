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
    
    func setup(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        setupPublicUserRecord { result in
            switch result {
            case .success:
                self.setupSharedUserRecord { result in
                    switch result {
                    case .success:
                        handler(.success(()))
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func fetch(then handler: @escaping (Result<User, CloudKitStoreError>) -> Void) {
        fetchPrivateUserRecord { result in
            switch result {
            case .success(let privateUserRecord):
                let user = User(privateUserRecord: privateUserRecord)
                handler(.success(user))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func save(user: User, then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        
        guard let privateUserRecordName = user.privateUserRecordName else { handler(.failure(.missingID)); return }
        guard let publicUserRecordName = user.publicUserRecordName else { handler(.failure(.missingID)); return }
        guard let sharedUserRecordName = user.sharedUserRecordName else { handler(.failure(.missingID)); return }
        
        let privateUserRecord = UserRecord(recordName: privateUserRecordName, user: user)
        
        savePrivateUserRecord(privateUserRecord) { result in
            switch result {
            case .success:
                print("success")
                let publicUserRecordID = CKRecord.ID(recordName: publicUserRecordName)
                let publicUser = PublicUserRecord(recordID: publicUserRecordID)
                publicUser.username = user.username
                
                if self.userDefaults.bool(forKey: "nameToPublicDb") {
                    publicUser.name = user.name
                }
                if self.userDefaults.bool(forKey: "bioToPublicDb") {
                    publicUser.bio = user.bio
                }
                if self.userDefaults.bool(forKey: "profilePictureToPublicDb") {
                    publicUser.profilePictureURL = user.profilePictureURL
                }
                
                self.savePublicUserRecord(publicUser) { result in
                    switch result {
                    case .success:
                        let sharedUserZone = CKRecordZone.ID(zoneName: "SharedWithFriendsDataZone")
                        let sharedUserRecordID = CKRecord.ID(
                            recordName: sharedUserRecordName,
                            zoneID: sharedUserZone
                        )
                        let sharedUser = SharedUserRecord(recordID: sharedUserRecordID)
                        
                        if self.userDefaults.bool(forKey: "nameSharedToFriends") {
                            sharedUser.name = user.name
                        }
                        if self.userDefaults.bool(forKey: "bioSharedToFriends") {
                            sharedUser.bio = user.bio
                        }
                        if self.userDefaults.bool(forKey: "profilePictureSharedToFriends") {
                            sharedUser.profilePictureURL = user.profilePictureURL
                        }
                        
                        self.saveSharedUserRecord(sharedUser) { result in
                            switch result {
                            case .success:
                                handler(.success(()))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                        
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

// MARK: Private User

extension UserManager {
    /// Asynchronously fetches the user record from the CloudKit database
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    func fetchPrivateUserRecord(then handler: @escaping (Result<UserRecord, CloudKitStoreError>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error as? CKError {
                handler(.failure(.ckError(error)))
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
                    handler(.failure(error))
                }
            }
        }
    }
    
    /// Saves modified private user record to the CloudKit database.
    /// - Parameters:
    ///   - record: The modified record to save,
    ///   - savePolicy: The save policy, Default is to overwrite only changed values.
    ///   - handler: What to do when the operation completes. Called with result (void if success or error).
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
                handler(.failure(error))
            }
        }
    }
}

// MARK: Public User

extension UserManager {
    /// Tries to fetch public user if it exists it will return as a success. If it is missing it will create the public user and return as a success.
    /// - Parameter handler: What to do when the operation completes. Returns void for success and error for failure.
    func setupPublicUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchPublicUserRecord { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                switch error {
                case .ckError(let ckError):
                    if ckError.code == .unknownItem {
                        self.createPublicUserRecord { result in
                            switch result {
                            case .success:
                                handler(.success(()))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    } else {
                        handler(.failure(error))
                    }
                case .missingID, .missingRecord:
                    self.createPublicUserRecord { result in
                        switch result {
                        case .success:
                            handler(.success(()))
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                default:
                    handler(.failure(error))
                }
            }
        }
    }
    
    /// Creates a new public user record and saves its record name to the private user.
    /// - Parameter handler: What to do when the operation completes. Returns void for success and error for failure.
    private func createPublicUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchPrivateUserRecord { result in
            switch result {
            case .success(let privateUserRecord):
                /// Create a new randomized record name and save it to the private record.
                let recordName = UUID().uuidString
                
                let newRecord = PublicUserRecord(recordID: CKRecord.ID(recordName: recordName))
                newRecord.username = privateUserRecord.username
                newRecord.privateUserRecordName = privateUserRecord.record.recordID.recordName
                
                self.cloudKitStore.saveRecord(newRecord.record, scope: .public) { result in
                    switch result {
                    case .success:
                        /// Update the private user record with the record name of the public user record.
                        privateUserRecord.publicUserRecordName = recordName
                        self.userDefaults.set(recordName, forKey: "publicUserRecordName")
                        self.savePrivateUserRecord(privateUserRecord) { result in
                            switch result {
                            case .success:
                                handler(.success(()))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    /// Fetch the public user record using record name in UserDefaults by default. If no value in UserDefaults, it will get it from private user record and if that doesnt exist, it'll fail with missingID error (this generally means it has not yet been created).
    /// - Parameter handler: <#handler description#>
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
                handler(.failure(error))
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
                handler(.failure(error))
            }
        }
    }
}

// MARK: Shared User

extension UserManager {
    func setupSharedUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchSharedUserRecord { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                switch result {
                case .success:
                    handler(.success(()))
                case .failure(let error):
                    switch error {
                    case .ckError(let ckError):
                        if ckError.code == .unknownItem {
                            self.createPublicUserRecord { result in
                                switch result {
                                case .success:
                                    handler(.success(()))
                                case .failure(let error):
                                    handler(.failure(error))
                                }
                            }
                        } else {
                            handler(.failure(error))
                        }
                    case .missingID, .missingRecord:
                        self.createPublicUserRecord { result in
                            switch result {
                            case .success:
                                handler(.success(()))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    default:
                        handler(.failure(error))
                    }
                }
            }
        }
    }
    
    /// Creates empty SharedWithFriendsData record for current user as well as a share and saves it to the private db.
    /// - Parameter handler: What to do when the operation completes.
    ///
    /// This method is required before inviting or sharing other users. It creates a zone named SharedWithFriendsDataZone for information shared with your friends in your private db. A SharedWithFriendsData record is created inside that zone and will hold all data that should be only shared with friends. This record should hold activity, competiton and user info or any other data that should be shared with friends depending on the users settings. A share is created with public permission set to none so that only invited users/friends can access the data. The **private** user record is modified to contain the URL to the share sharing the SharedWithFriendsDataRecord.
    private func createSharedUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        /// Create new  zone in your private db to share your activity data.
        cloudKitStore.createZone(named: "SharedWithFriendsDataZone") { result in
            switch result {
            case .success(let zone):
                self.fetchPrivateUserRecord { result in
                    switch result {
                    case .success(let userRecord):
                        /// Create an empty `SharedWithFriendsData` record in the created zone.
                        let sharedData = SharedUserRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                        sharedData.name = userRecord.name
                        sharedData.username = userRecord.username
                        sharedData.bio = userRecord.bio
                        sharedData.profilePictureURL = userRecord.profilePictureURL
                        
                        /// Create a share from the created activity record and set the public permission to none so no one can access it unless we explicitly allow them.
                        let share = CKShare(rootRecord: sharedData.record)
                        share.publicPermission = .none
                        
                        /// Operation to save the activity record and share.
                        let operation = CKModifyRecordsOperation(
                            recordsToSave: [sharedData.record, share],
                            recordIDsToDelete: nil
                        )
                        operation.qualityOfService = .userInitiated
                        
                        /// Placeholder for if saving share is successful.
                        var savedShare: CKShare?
                        
                        operation.perRecordCompletionBlock = { record, error in
                            if let error = error {
                                if let ckError = error as? CKError {
                                    handler(.failure(.ckError(ckError)))
                                }
                                handler(.failure(.other(error)))
                            }
                            if let record = record as? CKShare {
                                savedShare = record
                            }
                        }
                        
                        operation.completionBlock = {
                            guard let savedShare = savedShare, let url = savedShare.url else {
                                handler(.failure(.unknownError))
                                return
                            }
                            
                            /// Save the saved share url to the user record so it can be accessed later.
                            userRecord.sharedUserRecordName = sharedData.record.recordID.recordName
                            userRecord.friendShareURL = url.absoluteString
                            
                            self.userDefaults.set(sharedData.record.recordID.recordName, forKey: "sharedUserRecordName")
                            
                            self.savePrivateUserRecord(userRecord) { result in
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
        let zone = CKRecordZone.ID(zoneName: "SharedWithFriendsDataZone")
        let sharedUserRecordID = CKRecord.ID(recordName: recordName, zoneID: zone)
        
        cloudKitStore.fetchRecord(with: sharedUserRecordID, scope: .private) { result in
            switch result {
            case .success(let record):
                handler(.success(SharedUserRecord(record: record)))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func saveSharedUserRecord(
        _ record: SharedUserRecord,
        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        cloudKitStore.saveRecord(record.record, scope: .private, savePolicy: savePolicy) { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
