//
//  FriendsManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import CloudKit

class FriendsManager: ObservableObject {
    
    // MARK: Properties
    
    private let container: CKContainer
    private let cloudKitStore = CloudKitStore.shared
    private let userManager = UserManager.shared
    
    init(container: CKContainer = .appDefault) {
        self.container = container
    }
    
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
                handler(.failure(FriendsManagerError.unknownError))
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
                        handler(.failure(FriendsManagerError.unknownError))
                        return
                    }
                    print(identities)
                    
                    var friends: [Friend] = []
                    
                    for identity in identities {
                        let recordID = identity.userRecordID?.recordName ?? ""
                        let predicate = NSPredicate(format: "userRecordID == %@", recordID)
                        
                        CloudKitStore.shared.fetchRecords(
                            with: PublicUserRecord.self,
                            predicate: predicate,
                            scope: .public
                        ) { result in
                            switch result {
                            case .success(let records):
                                for user in records {
                                    friends.append(user.asFriend())
                                    
                                    if identity == identities.last && user.record == records.last?.record {
                                        handler(.success(friends))
                                    }
                                }
                            case .failure:
                                break
                            }
                        }
                    }
                }
            } else {
                handler(.failure(FriendsManagerError.insufficientPermissions))
            }
        }
    }
    
    // ** DONT USE ANYTHING BELOW YET **
    
    /// Creates empty SharedWithFriendsData record for current user as well as a share and saves it to the private db.
    /// - Parameter handler: What to do when the operation completes.
    ///
    /// This method is required before inviting or sharing other users. It creates a zone named SharedWithFriendsDataZone for information shared with your friends in your private db. A SharedWithFriendsData record is created inside that zone and will hold all data that should be only shared with friends. This record should hold activity, competiton and user info or any other data that should be shared with friends depending on the users settings. A share is created with public permission set to none so that only invited users/friends can access the data. The **private** user record is modified to contain the URL to the share sharing the SharedWithFriendsDataRecord.
    func beginSharing(completion: @escaping (Error?) -> Void) {
        /// Create new randomized zone in your private db to share your activity data.
        cloudKitStore.createZone(named: "SharedWithFriendsDataZone") { result in
            switch result {
            case .success(let zone):
                self.userManager.fetchPrivateUserRecord { result in
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
                                completion(error)
                            }
                            if let record = record as? CKShare {
                                savedShare = record
                            }
                        }
                        
                        operation.completionBlock = {
                            guard let savedShare = savedShare, let url = savedShare.url else {
                                completion(FriendsManagerError.unknownError)
                                return
                            }
                            
                            /// Save the saved share url to the user record so it can be accessed later.
                            userRecord.friendShareURL = url.absoluteString
                            self.userManager.savePrivateUserRecord(userRecord) { result in
                                switch result {
                                case .success:
                                    completion(nil)
                                case .failure(let error):
                                    completion(error)
                                }
                            }
                        }
                        
                        self.container.privateCloudDatabase.add(operation)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchFriends(completion: @escaping (Result<[Friend], Error>) -> Void) {
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let privateUserRecord):
                let friendShareURLs = privateUserRecord.friendShareURLs?.map { URL(string: $0)! } ?? []
                let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: friendShareURLs)
                metadataFetchOperation.qualityOfService = .userInitiated
                
                var friends: [Friend] = []
                
                metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
                    if let error = error {
                        completion(.failure(error))
                        print(error)
                        return
                    }
                    guard let metadata = metadata else { return }
                    let sharedUser = SharedUserRecord(record: metadata.rootRecord!)
                    let publicUserRecordID = CKRecord.ID(recordName: sharedUser.publicUserRecordName ?? "")
                    
                    let friend = Friend(
                        username: sharedUser.username ?? "",
                        name: sharedUser.name ?? "",
                        bio: sharedUser.bio ?? "",
                        profilePictureURL: sharedUser.profilePictureURL ?? "",
                        publicUserRecordID: publicUserRecordID,
                        privateUserRecordID: privateUserRecord.record.recordID
                    )
                    
                    friends.append(friend)
                }
                
                metadataFetchOperation.fetchShareMetadataCompletionBlock = { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    completion(.success(friends))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Friends Manager Error
    
    enum FriendsManagerError: Error {
        case unknownError
        case insufficientPermissions
    }
    
    enum FriendRequestType {
        case sent
        case received
        case all
    }
}
