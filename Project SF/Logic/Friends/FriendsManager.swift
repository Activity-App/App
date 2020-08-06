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
                        
                        CloudKitStore.shared.fetchRecords(
                            with: PublicUserRecord.self,
                            predicate: predicate,
                            scope: .public
                        ) { result in
                            switch result {
                            case .success(let records):
                                for user in records {
                                    //friends.append(user.asFriend())
                                    
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
                handler(.failure(.unknownError))
            }
        }
    }
    
    func fetchFriends(then handler: @escaping (Result<[Friend], CloudKitStoreError>) -> Void) {
        userManager.fetch { result in
            switch result {
            case .success(let user):
                let friendShareURLs = user.friendShareURLs?.map { URL(string: $0)! } ?? []
                let metadataFetchOperation = CKFetchShareMetadataOperation(shareURLs: friendShareURLs)
                metadataFetchOperation.shouldFetchRootRecord = true
                metadataFetchOperation.qualityOfService = .userInitiated
                
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

                    guard let metadata = metadata?.rootRecord else { handler(.failure(.missingRecord)); return }
                    let sharedUser = SharedUserRecord(record: metadata)
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
    
    func removeAllFriends() {
        userManager.fetchPrivateUserRecord { result in
            switch result {
            case .success(let record):
                record.friendShareURLs = []
                self.userManager.savePrivateUserRecord(record, then: { _ in })
            case .failure(let error):
                print(error)
            }
        }
    }
}
