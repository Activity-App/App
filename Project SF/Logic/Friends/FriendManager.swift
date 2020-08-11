//
//  FriendManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import CloudKit

class FriendManager: ObservableObject {
    
    // MARK: Properties
    
    private let container: CKContainer
    private let cloudKitStore: CloudKitStore
    private let userManager: UserManager
    
    // MARK: Init
    
    init(
        container: CKContainer = .appDefault,
        cloudKitStore: CloudKitStore = .shared,
        userManager: UserManager = .shared
    ) {
        self.container = container
        self.cloudKitStore = cloudKitStore
        self.userManager = userManager
    }
}

// MARK: Fetching

extension FriendManager {
    func fetchFriends(then handler: @escaping (Result<[Friend], CloudKitStoreError>) -> Void) {
        /// Get user record.
        userManager.fetch { result in
            switch result {
            case .success(let user):
                /// From the friend share urls list we need to fetch the underlying SharedUserRecord.
                let friendShareURLs = user.friendShareURLs?.map { URL(string: $0)! } ?? []
                let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: friendShareURLs)
                metadataFetchOperation.shouldFetchRootRecord = true
                metadataFetchOperation.qualityOfService = .userInitiated
                
                /// Placeholder values to hold incoming data.
                var friends: [Friend] = []
                var fetchError: CloudKitStoreError?
                
                metadataFetchOperation.perShareMetadataBlock = { _, metadata, error in
                    if let error = error {
                        if let ckError = error as? CKError {
                            fetchError = .ckError(ckError)
                            return
                        }
                        fetchError = .other(error)
                        return
                    }
                    /// Get the root record from the share metadata. This will be a `SharedUser`
                    guard let rootRecord = metadata?.rootRecord else { handler(.failure(.missingRecord)); return }
                    let sharedUser = SharedUserRecord(record: rootRecord)
                    guard let privateUserRecordName = sharedUser.privateUserRecordName,
                          let publicUserRecordName = sharedUser.publicUserRecordName else {
                        handler(.failure(.missingID))
                        return
                    }
                    let privateUserRecordID = CKRecord.ID(recordName: privateUserRecordName)
                    let publicUserRecordID = CKRecord.ID(recordName: publicUserRecordName)
                    
                    let friendActivity = ActivityRings(
                        moveCurrent: Double(sharedUser.move ?? 0),
                        moveGoal: Double(sharedUser.moveGoal ?? 300),
                        exerciseCurrent: Double(sharedUser.exercise ?? 0),
                        exerciseGoal: Double(sharedUser.exerciseGoal ?? 30),
                        standCurrent: Double(sharedUser.stand ?? 0),
                        standGoal: Double(sharedUser.standGoal ?? 12)
                    )
                    
                    let friend = Friend(
                        username: sharedUser.username ?? "",
                        name: sharedUser.name ?? "",
                        bio: sharedUser.bio ?? "",
                        profilePictureURL: sharedUser.profilePictureURL ?? "",
                        activityRings: friendActivity,
                        publicUserRecordID: publicUserRecordID,
                        privateUserRecordID: privateUserRecordID
                    )
                    friends.append(friend)
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
                    if let error = fetchError {
                        handler(.failure(error))
                        return
                    }
                    handler(.success(friends))
                }
                
                self.container.add(metadataFetchOperation)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: Contact Discovery

extension FriendManager {
    /// Requests permission from the user to discover their contacts.
    /// - Parameter handler: The result handler. Not guaranteed to be executed on the main thread.
    /// - Tag: requestDiscoveryPermission
    func requestDiscoveryPermission(then handler: @escaping (Result<Bool, CloudKitStoreError>) -> Void) {
        container.requestApplicationPermission([.userDiscoverability]) { (status, error) in
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            switch status {
            case .granted:
                handler(.success(true))
            case .denied:
                handler(.success(false))
            default:
                handler(.failure(.unknownError))
            }
        }
    }
    
    /// Asynchronously discovers the users friends. Fails if the adequate permissions have not been granted (you can request the required permission using [requestDiscoveryPermission](x-source-tag://requestDiscoveryPermission).
    /// - Parameter handler: The result handler. Not guaranteed to be executed on the main thread.
    func discoverFriends(then handler: @escaping (Result<[Friend], CloudKitStoreError>) -> Void) {
        container.status(forApplicationPermission: .userDiscoverability) { [weak container] status, error in
            guard let container = container else { return }
            if let error = error {
                if let ckError = error as? CKError {
                    handler(.failure(.ckError(ckError)))
                    return
                }
                handler(.failure(.other(error)))
                return
            }
            if case .granted = status {
                container.discoverAllIdentities { identities, error in
                    if let error = error {
                        if let ckError = error as? CKError {
                            handler(.failure(.ckError(ckError)))
                            return
                        }
                        handler(.failure(.other(error)))
                        return
                    }
                    guard let identities = identities else {
                        handler(.failure(.unknownError))
                        return
                    }
                    print(identities)
                    
                    var friends: [Friend] = []
                    
                    for identity in identities {
                        let recordID = identity.userRecordID?.recordName ?? ""
                        let predicate = NSPredicate(format: "userRecordID == %@", recordID)
                        
                        self.cloudKitStore.fetchRecords(
                            with: PublicUserRecord.self,
                            predicate: predicate,
                            scope: .public
                        ) { result in
                            result.get(handler) { records in
                                for user in records {
                                    //friends.append(user.asFriend())
                                    
                                    if identity == identities.last && user.record == records.last?.record {
                                        handler(.success(friends))
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                handler(.failure(.unknownError))
            }
        }
    }
}
