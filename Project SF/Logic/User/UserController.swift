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
    
    private var userRecord: UserRecord?
    var userInfoRecord: UserInfoRecord?
    
    @Published var user: User?
    
    @Published var loading = false
    
    /// Creates a `UserInfo` record and saves it to the public DB.
    /// - Parameter completion: What to do when the operation completes. Optional error is there if something fails.
    func createUserInfoRecord(completion: @escaping (Error?) -> Void) {
        guard let userRecord = userRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        loading = true
        
        let recordName = UUID().uuidString
        userRecord.userInfoRecordName = recordName
        
        syncUser { error in
            if let error = error {
                completion(error)
            } else {
                let newRecord = UserInfoRecord(recordID: CKRecord.ID(recordName: recordName))
                newRecord.userRecordName = userRecord.record.recordID.recordName
                
                self.cloudKitStore.saveRecord(newRecord.record, scope: .public) { result in
                    DispatchQueue.main.async {
                        self.loading = false
                        switch result {
                        case .success:
                            self.updateUserInfo { error in
                                if let error = error {
                                    completion(error)
                                } else {
                                    completion(nil)
                                }
                            }
                        case .failure(let error):
                            completion(error)
                        }
                    }
                }
            }
        }
    }
    
    /// Set user data in the cloud.
    /// - Parameters:
    ///   - data: The data to save. Initialise a `User` with the values you would like to update in the cloud.
    ///   - publicDb: Should applicable user info data be saved in the public db.
    ///   - completion: What should happen when the operation is completed.
    func set(data: User, publicDb: Bool, completion: @escaping (Error?) -> Void) {
        guard let userInfoRecord = userInfoRecord, let userRecord = userRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        if let name = data.name {
            userRecord.name = name
            userInfoRecord.name = name
        }
        if let username = data.username {
            userRecord.username = username
            userInfoRecord.username = username
        }
        if let bio = data.bio {
            userRecord.bio = bio
            userInfoRecord.bio = bio
        }
        if let pfp = data.profilePictureURL {
            userRecord.profilePictureURL = pfp
            userInfoRecord.profilePictureURL = pfp
        }
        if let srZone = data.scoreRecordZoneName {
            userRecord.scoreRecordZoneName = srZone
        }
        if let srRecordName = data.scoreRecordRecordName {
            userRecord.scoreRecordRecordName = srRecordName
        }
        if let srShareURL = data.scoreRecordPublicShareURL {
            userRecord.scoreRecordPublicShareURL = srShareURL
        }
        if let friendShareURL = data.friendShareURL {
            userRecord.friendShareURL = friendShareURL
        }
        
        syncUser { error in
            if let error = error {
                self.loading = false
                completion(error)
            } else {
                self.tryToSyncUserInfoToPrivateDb()
                if publicDb {
                    self.syncUserInfo { error in
                        self.loading = false
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Update local values for `Users` record with values from the cloud.
    /// - Parameter completion: What should happen when the operation is completed.
    func updateUser(completion: @escaping (Error?) -> Void) {
        loading = true
        
        cloudKitStore.fetchUserRecord { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let record):
                    self.userRecord = record
                    self.user = self.userRecord.map {
                        User(
                            name: $0.name,
                            username: $0.username,
                            bio: $0.bio,
                            profilePictureURL: $0.profilePictureURL,
                            scoreRecordZoneName: $0.scoreRecordZoneName,
                            scoreRecordRecordName: $0.scoreRecordRecordName,
                            scoreRecordPublicShareURL: $0.scoreRecordPublicShareURL
                        )
                    }
                    self.loading = false
                    completion(nil)
                case .failure(let error):
                    self.loading = false
                    completion(error)
                }
            }
        }
    }
    
    /// Update local values for `UserInfo` record with values from the **PUBLIC** db.
    /// This should only be used if you want to fetch specifically from the public db. Use `updateUser` for guaranteed results.
    /// - Parameter completion: What should happen when the operation is completed.
    func updateUserInfo(completion: @escaping (Error?) -> Void) {
        guard let userRecord = userRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        loading = true
        
        let recordID = CKRecord.ID(recordName: userRecord.userInfoRecordName ?? "")
        cloudKitStore.fetchRecord(with: recordID, scope: .public) { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let record):
                    self.userInfoRecord = UserInfoRecord(record: record)
                    self.user?.name = self.userInfoRecord!.name
                    self.user?.username = self.userInfoRecord!.username
                    self.user?.bio = self.userInfoRecord!.bio
                    self.user?.profilePictureURL = self.userInfoRecord!.profilePictureURL
                    self.loading = false
                    completion(nil)
                case .failure(let error):
                    self.loading = false
                    completion(error)
                }
            }
        }
    }
    
    /// Expose user info to the public db.
    /// - Parameter completion: What should happen when the operation is completed.
    func makeUserInfoPublic(completion: @escaping (Error?) -> Void) {
        guard let userInfoRecord = userInfoRecord, let userRecord = userRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        userInfoRecord.name = userRecord.name
        userInfoRecord.username = userRecord.username
        userInfoRecord.bio = userRecord.bio
        userInfoRecord.profilePictureURL = userRecord.profilePictureURL
        
        syncUserInfo { error in
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
    func makeUserInfoPrivate(completion: @escaping (Error?) -> Void) {
        guard let userInfoRecord = userInfoRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        
        loading = true
        
        userInfoRecord.name = ""
        userInfoRecord.username = ""
        userInfoRecord.bio = ""
        userInfoRecord.profilePictureURL = ""
        
        syncUserInfo { error in
            self.loading = false
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Private Methods
    
    /// Sync changes to the `userRecord` property to the cloud.
    /// - Parameter completion: What should happen when the operation is completed.
    private func syncUser(completion: @escaping (Error?) -> Void) {
        guard let userRecord = userRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        loading = true
        
        cloudKitStore.saveUserRecord(userRecord, savePolicy: .changedKeys) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updateUser { error in
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
    
    /// Tries to sync user info to the UserInfo record in the SharedToFriendsDataZone. This ensures data shared and public data is kept in sync. You should favor getting data from the public data if it is available rather than the shared db. This is only a backup for when the user does not want to store their data in the public db.XDDFG
    private func tryToSyncUserInfoToPrivateDb() {
        guard let userInfoRecord = userInfoRecord else { return }
        let zone = CKRecordZone.ID(zoneName: "SharedToFriendsDataZone")
        cloudKitStore.fetchRecords(with: "UserInfo", zone: zone, scope: .private) { result in
            switch result {
            case .success(let records):
                /// There was an existing user info record in the shared to friends data zone.
                guard let record = records.first else { return }
                let newRecord = UserInfoRecord(record: record)
                newRecord.name = userInfoRecord.name
                newRecord.username = userInfoRecord.username
                newRecord.bio = userInfoRecord.bio
                newRecord.profilePictureURL = userInfoRecord.profilePictureURL
                self.cloudKitStore.saveRecord(newRecord.record, scope: .private) { result in
                    switch result {
                    case .success:
                        print("Done")
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Sync changes to the `userInfoRecord` property to the cloud.
    /// - Parameter completion: What should happen when the operation is completed.
    private func syncUserInfo(completion: @escaping (Error?) -> Void) {
        guard let userInfoRecord = userInfoRecord else {
            completion(UserControllerError.doesNotExist)
            return
        }
        loading = true
        
        cloudKitStore.saveRecord(userInfoRecord.record, scope: .public) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updateUserInfo { error in
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
    
    // MARK: UserControllerError
    
    enum UserControllerError: Error {
        case doesNotExist
        case couldNotSync
        case couldNotUpdate
        case unknownError
    }
}
