//
//  UserManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 31/7/20.
//

import CloudKit

final class UserManager {
    
    // MARK: Properties
    
    static let shared = UserManager()
    
    private let container: CKContainer
    private let cloudKitStore: CloudKitStore
    private let userDefaults = UserDefaults.standard
    
    private var privateUserRecord: UserRecord?
    
    // MARK: Init
    
    private init(
        container: CKContainer = .appDefault,
        cloudKitStore: CloudKitStore = .shared
    ) {
        self.container = container
        self.cloudKitStore = cloudKitStore
    }
}

// MARK: Default Methods

extension UserManager {
    /// Setup the user. Checks for and creates a public and shared user record if they don't exist.
    func setup(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        setupPublicUserRecord { result in
            result.get(handler) {
                self.setupSharedUserRecord { result in
                    result.complete(handler)
                }
            }
        }
    }
    
    /// Fetch the current properties of the user as a User struct.
    func fetch(then handler: @escaping (Result<User, CloudKitStoreError>) -> Void) {
        if let privateUserRecord = privateUserRecord {
            let user = User(privateUserRecord: privateUserRecord)
            handler(.success(user))
            return
        } else {
            fetchPrivateUserRecord { result in
                result.get(handler) { record in
                    let user = User(privateUserRecord: record)
                    handler(.success(user))
                }
            }
        }
    }
    
    /// Save user properties to the cloud. This method will respect the privacy settings the user has set and should be preferred whenever a save is initiated by the user and not the system.
    /// - Parameters:
    ///   - user: The user struct with new updated values that should be saved. Only changed values will be saved.
    func save(user: User, then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        
        guard let privateUserRecordName = user.privateUserRecordName else { handler(.failure(.missingID)); return }
        guard let publicUserRecordName = user.publicUserRecordName else { handler(.failure(.missingID)); return }
        guard let sharedUserRecordName = user.sharedUserRecordName else { handler(.failure(.missingID)); return }
        
        let privateUserRecord = UserRecord(recordName: privateUserRecordName, user: user)
        
        savePrivateUserRecord(privateUserRecord) { result in
            result.get(handler) {
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
                    result.get(handler) {
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
                        if self.userDefaults.bool(forKey: "profilePictureSharedToFriends") {
                            sharedUser.profilePictureURL = user.profilePictureURL
                        }
                        if let activity = user.activity {
                            sharedUser.move = Int(activity.moveCurrent)
                            sharedUser.moveGoal = Int(activity.moveGoal)
                            sharedUser.exercise = Int(activity.exerciseCurrent)
                            sharedUser.exerciseGoal = Int(activity.exerciseGoal)
                            sharedUser.stand = Int(activity.standCurrent)
                            sharedUser.standGoal = Int(activity.standGoal)
                            sharedUser.steps = activity.steps
                            sharedUser.distance = activity.distance
                        }
                        
                        self.saveSharedUserRecord(sharedUser) { result in
                            result.complete(handler)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Private User

extension UserManager {
    /// Asynchronously fetches the user record from the CloudKit database
    /// - Parameter handler: Called with the result of the operation. Not guaranteed to be on the main thread.
    private func fetchPrivateUserRecord(then handler: @escaping (Result<UserRecord, CloudKitStoreError>) -> Void) {
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
                result.get(handler) { record in
                    let userRecord = UserRecord(record: record)
                    self.privateUserRecord = userRecord
                    handler(.success(userRecord))
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
            result.get(handler) {
                self.privateUserRecord = record
                handler(.success(()))
            }
        }
    }
}

// MARK: Public User

extension UserManager {
    /// Tries to fetch public user if it exists it will return as a success. If it is missing it will create the public user and return as a success.
    /// - Parameter handler: What to do when the operation completes. Returns void for success and error for failure.
    private func setupPublicUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchPublicUserRecord { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                switch error {
                case .ckError(let ckError):
                    if ckError.code == .unknownItem {
                        self.createPublicUserRecord { result in
                            result.complete(handler)
                        }
                    } else {
                        handler(.failure(error))
                    }
                case .missingID, .missingRecord:
                    self.createPublicUserRecord { result in
                        result.complete(handler)
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
        fetch { result in
            result.get(handler) { user in
                var user = user
                guard let privateUserRecordName = user.privateUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                /// Create a new randomized record name and save it to the private record.
                let recordName = UUID().uuidString
                
                let newRecord = PublicUserRecord(recordID: CKRecord.ID(recordName: recordName))
                newRecord.username = user.username
                newRecord.privateUserRecordName = privateUserRecordName
                
                self.cloudKitStore.saveRecord(newRecord.record, scope: .public) { result in
                    result.get(handler) {
                        /// Update the private user record with the record name of the public user record.
                        user.publicUserRecordName = recordName
                        
                        let privateUser = UserRecord(recordName: privateUserRecordName, user: user)
                        self.savePrivateUserRecord(privateUser) { result in
                            result.complete(handler)
                        }
                    }
                }
            }
        }
    }
    
    /// Fetch the public user record using record name in UserDefaults by default. If no value in UserDefaults, it will get it from private user record and if that doesnt exist, it'll fail with missingID error (this generally means it has not yet been created).
    /// - Parameter handler: <#handler description#>
    func fetchPublicUserRecord(then handler: @escaping (Result<PublicUserRecord, CloudKitStoreError>) -> Void) {
        fetch { result in
            result.get(handler) { user in
                guard let publicUserRecordName = user.publicUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                let publicUserRecordID = CKRecord.ID(recordName: publicUserRecordName)
                
                self.cloudKitStore.fetchRecord(with: publicUserRecordID, scope: .public) { result in
                    result.get(handler) { record in
                        handler(.success(PublicUserRecord(record: record)))
                    }
                }
            }
        }
    }
    
    func savePublicUserRecord(
        _ record: PublicUserRecord,
        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        cloudKitStore.saveRecord(record.record, scope: .public, savePolicy: savePolicy) { result in
            result.complete(handler)
        }
    }
}

// MARK: Shared User

extension UserManager {
    private func setupSharedUserRecord(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        fetchSharedUserRecord { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                switch error {
                case .ckError(let ckError):
                    if ckError.code == .unknownItem {
                        self.createSharedUserRecord { result in
                            result.complete(handler)
                        }
                    } else {
                        handler(.failure(error))
                    }
                case .missingID, .missingRecord:
                    self.createSharedUserRecord { result in
                        result.complete(handler)
                    }
                default:
                    handler(.failure(error))
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
            result.get(handler) { zone in
                self.fetch { result in
                    result.get(handler) { user in
                        var user = user
                        guard let privateUserRecordName = user.privateUserRecordName else {
                            handler(.failure(.missingID))
                            return
                        }
                        
                        /// Create an empty `SharedWithFriendsData` record in the created zone.
                        let sharedData = SharedUserRecord(recordID: CKRecord.ID(zoneID: zone.zoneID))
                        sharedData.name = user.name
                        sharedData.username = user.username
                        sharedData.bio = user.bio
                        sharedData.profilePictureURL = user.profilePictureURL
                        sharedData.privateUserRecordName = user.privateUserRecordName
                        sharedData.publicUserRecordName = user.publicUserRecordName
                        
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
                            
                            user.sharedUserRecordName = sharedData.record.recordID.recordName
                            user.friendShareURL = url.absoluteString
                            
                            let privateUser = UserRecord(recordName: privateUserRecordName, user: user)
                            self.savePrivateUserRecord(privateUser) { result in
                                result.complete(handler)
                            }
                        }
                        
                        self.container.privateCloudDatabase.add(operation)
                    }
                }
            }
        }
    }
    
    func fetchSharedUserRecord(then handler: @escaping (Result<SharedUserRecord, CloudKitStoreError>) -> Void) {
        fetch { result in
            result.get(handler) { user in
                guard let sharedUserRecordName = user.sharedUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                let zone = CKRecordZone.ID(zoneName: "SharedWithFriendsDataZone")
                let sharedUserRecordID = CKRecord.ID(recordName: sharedUserRecordName, zoneID: zone)
                
                self.cloudKitStore.fetchRecord(with: sharedUserRecordID, scope: .private) { result in
                    result.get(handler) { record in
                        handler(.success(SharedUserRecord(record: record)))
                    }
                }
            }
        }
    }
    
    func saveSharedUserRecord(
        _ record: SharedUserRecord,
        savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .changedKeys,
        then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        cloudKitStore.saveRecord(record.record, scope: .private, savePolicy: savePolicy) { result in
            result.complete(handler)
        }
    }
}
