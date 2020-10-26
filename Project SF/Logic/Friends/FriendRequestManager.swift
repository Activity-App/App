//
//  FriendRequestManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 31/7/20.
//

import CloudKit
import UIKit

class FriendRequestManager {
    
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

// MARK: Notifications

extension FriendRequestManager {
    /// Subscribe to new friend requests sent to the current user. A silent notification with the invite data will be sent and handled in the AppDelegate.
    /// - Parameter handler: What to do when the operation completes.
    func subscribeToFriendRequests(then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        userManager.fetch { result in
            result.get(handler) { user in
                guard let privateUserRecordName = user.privateUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                let predicate = NSPredicate(
                    format: "recipientRecordName = %@", privateUserRecordName
                )
                let subscription = CKQuerySubscription(
                    recordType: "FriendRequest",
                    predicate: predicate,
                    options: .firesOnRecordCreation
                )
                
                let notification = CKSubscription.NotificationInfo()
                notification.shouldSendContentAvailable = true
                
                subscription.notificationInfo = notification
                
                self.container.publicCloudDatabase.save(subscription) { _, error in
                    if let error = error {
                        if let ckError = error as? CKError {
                            handler(.failure(.ckError(ckError)))
                            return
                        }
                        handler(.failure(.other(error)))
                        return
                    }
                    handler(.success(()))
                }
            }
        }
    }
}

// MARK: Fetching

extension FriendRequestManager {
    /// Fetch friend requests from the public db of a specified type.
    /// - Parameters:
    ///   - type: If you want to fetch requests sent, received or both.
    ///   - handler: What to do when the operation completes. Called with a result of friend request records if a success or a CloudKitStoreError if failure.
    ///
    /// This function uses ternery operators and predicates in order to fetch the right friend request records. It is just a basic fetch with some predicate logic.
    func fetchFriendRequests(type: FriendRequestType, then handler: @escaping (Result<[FriendRequestRecord], CloudKitStoreError>) -> Void) {
        /// Get current user.
        userManager.fetch { result in
            result.get(handler) { user in
                /// Fetch only friend requests that have been sent or received not accepted.
                guard let privateUserRecordName = user.privateUserRecordName else {
                    print("missing here")
                    handler(.failure(.missingID))
                    return
                }
                let recordNamePredicate = NSPredicate(
                    format: type == .received ? "recipientPrivateUserRecordName == %@" : "creatorPrivateUserRecordName == %@",
                    privateUserRecordName
                )
                let acceptedPredicate = NSPredicate(format: "accepted == false")
                let allPredicates = [recordNamePredicate, acceptedPredicate]
                
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
                
                self.cloudKitStore.fetchRecords(with: FriendRequestRecord.self, predicate: predicate, scope: .public) { result in
                    result.get(handler) { friendRequests in
                        handler(.success(friendRequests))
                    }
                }
            }
        }
    }
    
    /// Convert FriendRequestRecord to FriendRequest to be used in UI.
    /// - Parameters:
    ///   - friendRequestRecord: The friend request record.
    ///   - type: The type of friend request.
    func recordToStruct(
        friendRequestRecord: FriendRequestRecord,
        type: FriendRequestType,
        handler: @escaping (Result<FriendRequest, CloudKitStoreError>) -> Void
    ) {
//        guard let creatorPublicUserRecordName = friendRequestRecord.creatorPublicUserRecordName,
//              let recipientPublicUserRecordName = friendRequestRecord.recipientPublicUserRecordName
//        else {
//            handler(.failure(.missingID))
//            return
//        }
        
        userManager.fetch { result in
            result.get(handler) { user in
                
                /// If it is a record we have received, we should fetch the creators info otherwise we should fetch the person we sent the request to info.
                let recordID = CKRecord.ID(
                    recordName: type == .received ? friendRequestRecord.creatorPublicUserRecordName! : friendRequestRecord.recipientPublicUserRecordName!
                )
                self.cloudKitStore.fetchRecord(with: recordID, scope: .public) { result in
                    result.get(handler) { userRecordRaw in
                        let userRecord = PublicUserRecord(record: userRecordRaw)
                        if type == .received {
                            let friendRequest = FriendRequest(
                                recipientName: user.name,
                                creatorName: userRecord.name,
                                recipientUsername: user.username!,
                                creatorUsername: userRecord.username!,
                                recipientProfilePicture: nil,
                                creatorProfilePicture: nil,
                                record: friendRequestRecord
                            )
                            handler(.success(friendRequest))
                        } else {
                            let friendRequest = FriendRequest(
                                recipientName: userRecord.name,
                                creatorName: user.name,
                                recipientUsername: userRecord.username!,
                                creatorUsername: user.username!,
                                recipientProfilePicture: nil,
                                creatorProfilePicture: nil,
                                record: friendRequestRecord
                            )
                            handler(.success(friendRequest))
                        }
                    }
                }
            }
        }
    }
    
    /// Enum used to specify which type of friend requests you would like to fetch in `fetchFriendRequests`.
    enum FriendRequestType {
        /// Requests sent by user.
        case sent
        /// Requests sent to user.
        case received
    }
}

// MARK: Inviting

extension FriendRequestManager {
    /// Create a singular friend request to a friend and save it to the public db.
    /// - Parameters:
    ///   - friend: The friend you would like to invite.
    ///   - handler: What to do when the operation completes.
    ///
    /// See the `invite(friends: [Friends])` method for more documentation.
    func invite(user: String, then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        invite(users: [user], then: handler)
    }
    
    /// Creates friend requests for each friend in the array of friends input in the public db.
    /// - Parameters:
    ///   - users: The users you would like to invite. Array of private user record names.
    ///   - handler: What to do when the operation completes.
    ///
    /// We use a `CKFetchShareMetadataOperation` to get the metadata for the current users share URL. This metadata includes the share itself. We then convert the friends into CKShare.Participants and add them to the share as participants that can read only. The changes to the share are then saved. Upon completion of adding the participants to the share, we create the friend requests to be stored in the public db so other users can see if they have pending friend requests in which they can accept from the share url. It is ok to make this public as the public permission for the share is set to none and only people we have added as participants will be able to read the data.
    func invite(users: [String], then handler: @escaping (Result<Void, CloudKitStoreError>) -> Void) {
        /// Get the current user record.
        
        userManager.fetch { result in
            result.get(handler) { user in
                /// Get the friend share url from the fetched user record.
                guard let shareURLString = user.friendShareURL,
                      let shareURL = URL(string: shareURLString) else {
                    handler(.failure(.unknownError))
                    return
                }

                self.cloudKitStore.fetchShare(with: shareURL) { result in
                    result.get(handler) { share in
                        /// Convert friends into CKShare Participants.
                        self.cloudKitStore.fetchShareParticipantsFromRecordNames(users: users) { result in
                            result.get(handler) { participants in
                                /// Set the friends to have read access to the share. This will let them access your shared user data.
                                for participant in participants {
                                    participant.permission = .readOnly
                                    share.addParticipant(participant)
                                }
                                
                                self.cloudKitStore.saveRecord(share, scope: .private) { result in
                                    result.get(handler) {
                                        /// Invite the friends by creating an invite with the friends user record name and save it to the public db.
                                        var inviteRecords: [FriendRequestRecord] = []
                                        
                                        for userRecordName in users {
                                            let invite = FriendRequestRecord()
                                            invite.recipientPrivateUserRecordName = userRecordName
                                            invite.creatorPublicUserRecordName = user.publicUserRecordName
                                            invite.creatorPrivateUserRecordName = user.privateUserRecordName
                                            invite.creatorShareURL = share.url?.absoluteString
                                            invite.accepted = false
                                            inviteRecords.append(invite)
                                        }
                                        
                                        self.cloudKitStore.saveRecords(inviteRecords.map { $0.record }, scope: .public) { result in
                                            result.complete(handler)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Accepting

extension FriendRequestManager {
    /// Fetches requests that the user has sent and accepted by the recipient. It saves the recipients share url to the list of friend share urls and then deletes the friend request record.
    /// - Parameter handler: What to do when the operation completes. This will be called with a result.
    func cleanAcceptedRequests(then handler: @escaping (Result<[FriendRequestRecord], CloudKitStoreError>) -> Void) {
        /// Get current user.
        userManager.fetch { result in
            result.get(handler) { user in
                var user = user
                guard let privateUserRecordName = user.privateUserRecordName,
                      let publicUserRecordName = user.publicUserRecordName else {
                    handler(.failure(.missingID))
                    return
                }
                /// Create a predicate that will only fetch records that have been sent and accepted.
                let creatorPredicate = NSPredicate(format: "creatorPublicUserRecordName = %@", publicUserRecordName)
                let acceptedPredicate = NSPredicate(format: "accepted == true")
                let allPredicates = [creatorPredicate, acceptedPredicate]
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
                
                self.cloudKitStore.fetchRecords(with: FriendRequestRecord.self, predicate: predicate, scope: .public) { result in
                    result.get(handler) { friendRequests in
                        /// If there are no results then there is nothing to do and therefore the operation is a success.
                        print(friendRequests)
                        guard !friendRequests.isEmpty else { handler(.success([])); return }
                        
                        var deletedFriendRequest: [FriendRequestRecord] = []
                        
                        /// Only iterate over friend requests where the recipient has accepted and added their shareURL.
                        for friendRequest in friendRequests where friendRequest.recipientShareURL != nil {
                            /// Make friendShareURLs empty if it is nil.
                            if user.friendShareURLs == nil {
                                user.friendShareURLs = []
                            }
                            /// Add the friend request recipient share url to the users array of friends share urls.
                            user.friendShareURLs!.append(friendRequest.recipientShareURL!)
                            let privateUserRecord = UserRecord(recordName: privateUserRecordName, user: user)
                            
                            self.userManager.savePrivateUserRecord(privateUserRecord) { result in
                                result.get(handler) {
                                    ///** The two users are now successfully friends yay! We can now safely delete the friend request from the public db. **
                                    let friendRequestRecordID = friendRequest.record.recordID
                                    self.cloudKitStore.deleteRecord(with: friendRequestRecordID, scope: .public) { result in
                                        result.get(handler) {
                                            deletedFriendRequest.append(friendRequest)
                                            /// If it is the last friend request in the list and it's all a success, we complete with a success.
                                            if friendRequests.last?.record.recordID.recordName == friendRequest.record.recordID.recordName {
                                                handler(.success(deletedFriendRequest))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Accept a pending friend request that was sent to the current user.
    /// - Parameters:
    ///   - friendRequest: The friend request to accept.
    ///   - handler: What to do when the operation completes. Called with a result that is void if a success or a CloudKitStoreError if failure.
    func acceptFriendRequest(
        _ friendRequest: FriendRequestRecord,
        handler: @escaping (Result<Void, CloudKitStoreError>) -> Void
    ) {
        userManager.fetch { result in
            result.get(handler) { user in
                var user = user
                /// Get the share url to the friend request creator. Leads to their SharedUserRecord. Also get the current user share url to their SharedUserRecord.
                guard let creatorShareURLString = friendRequest.creatorShareURL,
                      let creatorShareURL = URL(string: creatorShareURLString),
                      let creatorPrivateUserRecordName = friendRequest.creatorPrivateUserRecordName,
                      let friendShareURLString = user.friendShareURL,
                      let friendShareURL = URL(string: friendShareURLString),
                      let privateUserRecordName = user.privateUserRecordName
                else {
                    handler(.failure(.unknownError))
                    return
                }
                
                /// Fetch the users share so we can add the person who created the friend request as a participant to the share and therefore give them access to the SharedUserRecord.
                self.cloudKitStore.fetchShare(with: friendShareURL) { result in
                    result.get(handler) { share in
                        
                        /// Convert the creators record name into a CKShare Participant.
                        self.cloudKitStore.fetchShareParticipantsFromRecordNames(users: [creatorPrivateUserRecordName]) { result in
                            result.get(handler) { participants in
                                /// Add to users share.
                                for participant in participants {
                                    participant.permission = .readOnly
                                    share.addParticipant(participant)
                                }
                                
                                ///** Now we have to save the creators share url to our friend share url list to refer back to later when we want to read their data. **
                                
                                /// Make friendShareURLs empty if it is nil.
                                if user.friendShareURLs == nil {
                                    user.friendShareURLs = []
                                }
                                /// Add the friend request creators share url to the users array of friends share urls.
                                user.friendShareURLs!.append(creatorShareURL.absoluteString)
                                
                                let privateUserRecord = UserRecord(recordName: privateUserRecordName, user: user)
                                
                                self.cloudKitStore.saveRecords([share, privateUserRecord.record], scope: .private) { result in
                                    result.get(handler) {
                                        ///** Now that we have given them access to the users SharedUserRecord, we need to let them know we have done so. We do this by setting the invitation to accepted and adding our share url so they can then save and access it later. **
                                        friendRequest.recipientShareURL = user.friendShareURL
                                        friendRequest.accepted = true
                                        self.cloudKitStore.saveRecord(friendRequest.record, scope: .public) { result in
                                            result.get(handler) {
                                                self.cloudKitStore.saveRecord(share, scope: .private) { result in
                                                    result.complete(handler)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
