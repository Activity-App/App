//
//  FriendsController.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import CloudKit
import UIKit

class FriendController: ObservableObject {
    
    private var manager = FriendsManager()
    private var requestManager = FriendRequestManager()
    
    @Published var friends: [Friend] = []
    @Published var discoveredFriends: [Friend] = []
    @Published var sentRequestsToFriends: [FriendRequestRecord] = []
    @Published var receivedRequestsFromFriends: [FriendRequest] = []
    @Published var sharingEnabled = UserDefaults.standard.bool(forKey: "sharingEnabled")
    
    func updateAll() {
        requestManager.fetchAndCleanAcceptedRequests { error in
            if let error = error { print(error); return }
            self.requestManager.fetchFriendRequests(type: .received) { result in
                switch result {
                case .success(let receivedFriendRequests):
                    
                    if receivedFriendRequests.isEmpty {
                        DispatchQueue.main.async {
                            self.receivedRequestsFromFriends = []
                            return
                        }
                    }
                    
                    var receivedRequests: [FriendRequest] = []
                    
                    for request in receivedFriendRequests {
                        let recordID = CKRecord.ID(recordName: request.creatorPublicUserRecordName ?? "")
                        CloudKitStore.shared.fetchRecord(with: recordID, scope: .public) { result in
                            switch result {
                            case .success(let creatorPublicUserRecordRaw):
                                let creatorPublicUserRecord = PublicUserRecord(record: creatorPublicUserRecordRaw)
                                let predicate = NSPredicate(format: "privateUserRecordName = %@", request.inviteePrivateUserRecordName ?? "")
                                CloudKitStore.shared.fetchRecords(with: PublicUserRecord.self, predicate: predicate, scope: .public) { result in
                                    switch result {
                                    case .success(let inviteePublicUserRecordRaw):
                                        guard let inviteePublicUserRecord = inviteePublicUserRecordRaw.first else { return }
                                        
                                        let friendRequest = FriendRequest(
                                            id: request.record.recordID.recordName,
                                            inviteeName: inviteePublicUserRecord.name,
                                            creatorName: creatorPublicUserRecord.name,
                                            inviteeUsername: inviteePublicUserRecord.username,
                                            creatorUsername: creatorPublicUserRecord.username,
                                            inviteeProfilePicture: nil,
                                            creatorProfilePicture: nil,
                                            record: request
                                        )
                                        print(friendRequest)
                                        receivedRequests.append(friendRequest)
                                        DispatchQueue.main.async {
                                            self.receivedRequestsFromFriends = receivedRequests
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    
                    self.requestManager.fetchFriendRequests(type: .sent) { result in
                        switch result {
                        case .success(let sentFriendRequests):
                            DispatchQueue.main.async {
                                self.sentRequestsToFriends = sentFriendRequests
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.receivedRequestsFromFriends = []
                    }
                    print(error)
                }
            }
        }
        manager.fetchFriends { result in
            switch result {
            case .success(let friends):
                print("fetched friends")
                DispatchQueue.main.async {
                    self.friends = friends
                }
            case .failure(let error):
                print("fetch friend error \(error)")
            }
        }
    }
}
