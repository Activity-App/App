//
//  UserController.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import CloudKit

/// Handles the user of the application in CloudKit.
///
/// The UserRecord will be always saved to your private database with your information. If you choose, you can make your information public. This is done through the UserInfoRecord. Use the `set` method with `publicDb` to `true` to set new specified information to be exposed to the public db or`makeUserInfoPublic` to set all current info(name, bio, pfp) to the public db. Conversely, you can use `makeUserInfoPrivate` to remove all user info from the public db.
class UserController: ObservableObject {
    
    // MARK: Properties
    
    private let cloudKitStore = CloudKitStore.shared
    private let manager = UserManager.shared
    
    private var privateUserRecord: UserRecord?
    private var publicUserRecord: PublicUserRecord?
    private var sharedUserRecord: SharedUserRecord?
    
    @Published var user: User?
    
    @Published var loading = false
    
    /// Creates a `PublicUser` record and saves it to the public DB.
    /// - Parameter completion: What to do when the operation completes. Optional error is there if something fails.
    func createPublicUserRecord(completion: @escaping (UserControllerError?) -> Void) {
        /// Look for currently saved private user.
        guard let privateUserRecord = privateUserRecord else {
            completion(.doesNotExist)
            return
        }
        loading = true
        
        /// Create a new randomized record name and save it to the private record.
        let recordName = UUID().uuidString
        
        let newRecord = PublicUserRecord(recordID: CKRecord.ID(recordName: recordName))
        newRecord.privateUserRecordName = privateUserRecord.record.recordID.recordName
        
        self.cloudKitStore.saveRecord(newRecord.record, scope: .public) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    /// Update the private user record with the record name of the public user record.
                    privateUserRecord.publicUserRecordName = recordName
                    self.syncPrivateUser { error in
                        if let error = error {
                            self.loading = true
                            completion(.cloudKitError(error))
                        } else {
                            /// Check it was saved correctly and update the `publicUserRecord`
                            self.updatePublicUser { error in
                                if let error = error {
                                    self.loading = false
                                    completion(.cloudKitError(error))
                                } else {
                                    self.loading = false
                                    completion(nil)
                                }
                            }
                        }
                    }
                    
                    print("here")
                case .failure(let error):
                    self.loading = false
                    completion(.cloudKitError(error))
                }
            }
        }
    }
    
    /// Set user data in the cloud.
    /// - Parameters:
    ///   - data: The data to save. Initialise a `User` with the values you would like to update in the cloud.
    ///   - publicDb: Should applicable user info data be saved in the public db.
    ///   - completion: What should happen when the operation is completed.
    func set(data: User, publicDb: Bool, completion: @escaping (UserControllerError?) -> Void) {
        guard let publicUserRecord = publicUserRecord, let privateUserRecord = privateUserRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        if let name = data.name {
            privateUserRecord.name = name
            publicUserRecord.name = name
        }
        if let username = data.username {
            privateUserRecord.username = username
            publicUserRecord.username = username
        }
        if let bio = data.bio {
            privateUserRecord.bio = bio
            publicUserRecord.bio = bio
        }
        if let pfp = data.profilePictureURL {
            privateUserRecord.profilePictureURL = pfp
            publicUserRecord.profilePictureURL = pfp
        }
        
        syncPrivateUser { error in
            if let error = error {
                self.loading = false
                completion(.cloudKitError(error))
            } else {
                //self.tryToSyncPublicUserToSharedUser()
                if publicDb {
                    self.syncPublicUser { error in
                        self.loading = false
                        if let error = error {
                            completion(.cloudKitError(error))
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    self.loading = false
                    completion(nil)
                }
            }
        }
    }
    
    /// Update local values for `Users` record with values from the private db.
    /// - Parameter completion: What should happen when the operation is completed.
    func updatePrivateUser(completion: @escaping (UserControllerError?) -> Void) {
        loading = true
        
        manager.fetchPrivateUserRecord { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let record):
                    self.privateUserRecord = record
                    if self.user?.updateWith(privateUserRecord: record) == nil {
                        self.user = User(privateUserRecord: record)
                    }
                    self.loading = false
                    completion(nil)
                case .failure(let error):
                    self.loading = false
                    completion(.cloudKitError(error))
                }
            }
        }
    }
    
    /// Update local values for `PublicUser` record with values from the public db.
    /// - Parameter completion: What should happen when the operation is completed.
    ///
    /// This should only be used if you want to fetch specifically from the public db. Use `updatePrivateUser` for guaranteed results.
    func updatePublicUser(completion: @escaping (UserControllerError?) -> Void) {
        loading = true
        
        manager.fetchPublicUserRecord { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let record):
                    self.publicUserRecord = record
                    if self.user?.updateWith(publicUserRecord: record) == nil {
                        self.user = User(publicUserRecord: record)
                    }
                    completion(nil)
                case .failure(let error):
                    completion(.cloudKitError(error))
                }
            }
        }
    }
    
//    func updateSharedUser(completion: @escaping (Result<Void, UserControllerError>) -> Void) {
//        loading = true
//        
//        manager.fetchSharedUserRecord { result in
//            DispatchQueue.main.async {
//                self.loading = false
//                switch result {
//                case .success(let record):
//                    self.sharedUserRecord = record
//                    completion(.success(()))
//                case .failure(let error):
//                    completion(.failure(.cloudKitError(error)))
//                }
//            }
//        }
//    }
    
    /// Expose user info to the public db.
    /// - Parameter completion: What should happen when the operation is completed.
    func makePrivateUserInfoPublic(completion: @escaping (Error?) -> Void) {
        guard let publicUserRecord = publicUserRecord, let privateUserRecord = privateUserRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        publicUserRecord.name = privateUserRecord.name
        publicUserRecord.username = privateUserRecord.username
        publicUserRecord.bio = privateUserRecord.bio
        publicUserRecord.profilePictureURL = privateUserRecord.profilePictureURL
        
        syncPublicUser { error in
            self.loading = false
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Hide user info from the public db.
    /// - Parameter completion: What should happen when the operation is completed.
    func makePublicUserInfoPrivate(completion: @escaping (Error?) -> Void) {
        guard let publicUserDataRecord = publicUserRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        publicUserDataRecord.name = ""
        publicUserDataRecord.username = ""
        publicUserDataRecord.bio = ""
        publicUserDataRecord.profilePictureURL = ""
        
        syncPublicUser { error in
            self.loading = false
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Private Methods
    
    /// Sync changes to the `privateUserRecord` property to the cloud.
    /// - Parameter completion: What should happen when the operation is completed.
    private func syncPrivateUser(completion: @escaping (Error?) -> Void) {
        guard let privateUserRecord = privateUserRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        loading = true
        
        manager.savePrivateUserRecord(privateUserRecord) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updatePrivateUser { error in
                        self.loading = false
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    self.loading = false
                    completion(error)
                }
            }
        }
    }
    
    /// Sync changes to the `privateUserRecord` property to the cloud.
    /// - Parameter completion: What should happen when the operation is completed.
    private func syncPublicUser(completion: @escaping (UserControllerError?) -> Void) {
        guard let publicUserRecord = publicUserRecord else {
            completion(.doesNotExist)
            return
        }
        loading = true
        
        cloudKitStore.saveRecord(publicUserRecord.record, scope: .public) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updatePublicUser { error in
                        self.loading = false
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    self.loading = false
                    completion(.cloudKitError(error))
                }
            }
        }
    }
    
    
    // MARK: UserControllerError
    
    enum UserControllerError: Error {
        case doesNotExist
        case unknownError
        case cloudKitError(Error)
    }
}
