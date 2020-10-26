//
//  FriendsController.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import CloudKit
import UIKit

class FriendController: ObservableObject {
    
    typealias Handler = (Result<Void, CloudKitStoreError>) -> Void
    
    private var manager = FriendManager()
    private var requestManager = FriendRequestManager()
    
    @Published var friends: [ExternalUser] = []
    @Published var sentFriendRequests: [FriendRequest] = []
    @Published var receivedFriendRequests: [FriendRequest] = []
    
    func setup(then handler: @escaping Handler) {
        updateRequests(type: .sent) { result in
            result.get(handler) {
                self.cleanAcceptedRequests { result in
                    result.get(handler) {
                        self.updateRequests(type: .received) { result in
                            result.get(handler) {
                                self.manager.fetchFriends { result in
                                    result.get(handler) { friends in
                                        DispatchQueue.main.async {
                                            self.friends = friends
                                            handler(.success(()))
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
    
    func updateActivityData(activityRings: ActivityRings, then handler: @escaping Handler) {
        self.manager.updateActivityData(activityRings: activityRings, then: handler)
    }
    
    // TODO: Make incremental updates in friend controller work.
    func incrementalUpdate(then handler: @escaping Handler) {
        self.updateRequests(type: .received) { result in
            result.get(handler) {
                self.cleanAcceptedRequests(then: handler)
            }
        }
    }
    
    func acceptRequest(_ request: FriendRequest, handler: @escaping Handler) {
        requestManager.acceptFriendRequest(request.record) { result in
            result.get(handler) {
                self.updateRequests(type: .received) { result in
                    result.get(handler) {
                        self.manager.fetchFriends { result in
                            result.get(handler) { friends in
                                DispatchQueue.main.async {
                                    self.friends = friends
                                    handler(.success(()))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendRequest(to user: User, then handler: @escaping Handler) {
        guard let privateUserRecordName = user.privateUserRecordName else {
            handler(.failure(.missingID))
            return
        }
        requestManager.invite(user: privateUserRecordName) { result in
            result.complete(handler)
        }
    }
    
    private func updateRequests(
        type: FriendRequestManager.FriendRequestType,
        then handler: @escaping Handler
    ) {
        /// Fetch requests the current user has sent.
        requestManager.fetchFriendRequests(type: type) { result in
            result.get(handler) { sentFriendRequestsResult in
                guard !sentFriendRequestsResult.isEmpty else { handler(.success(())); return }
                DispatchQueue.main.async {
                    switch type {
                    case .received:
                        self.receivedFriendRequests = []
                    case .sent:
                        self.sentFriendRequests = []
                    }
                }
                var count = 0
                for request in sentFriendRequestsResult {
                    /// Convert sent requests to friend request structs.
                    self.requestManager.recordToStruct(friendRequestRecord: request, type: type) { result in
                        result.get(handler) { friendRequest in
                            DispatchQueue.main.async {
                                switch type {
                                case .received:
                                    self.receivedFriendRequests.append(friendRequest)
                                case .sent:
                                    self.sentFriendRequests.append(friendRequest)
                                }
                            }
                            count += 1
                            if count == sentFriendRequestsResult.count {
                                handler(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func cleanAcceptedRequests(then handler: @escaping Handler) {
        requestManager.cleanAcceptedRequests { result in
            result.get(handler) { deletedFriendRequests in
                guard !deletedFriendRequests.isEmpty else { handler(.success(())); return }
                for request in deletedFriendRequests {
                    self.sentFriendRequests.removeAll { $0.record.record.recordID == request.record.recordID }
                    handler(.success(()))
                }
            }
        }
    }
}
