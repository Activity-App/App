//
//  FriendsController.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import Foundation

class FriendController: ObservableObject {
    
    private var manager = FriendsManager()
    
    @Published var friends: [Friend] = []
    @Published var discoveredFriends: [Friend] = []
    @Published var sentRequestsToFriends: [FriendRequestRecord] = []
    @Published var receievedRequestsFromFriends: [FriendRequestRecord] = []
    @Published var sharingEnabled = UserDefaults.standard.bool(forKey: "sharingEnabled")
    
    func updateAll() {
        manager.fetchFriendRequests(type: .received) { result in
            switch result {
            case .success(let receivedFriendRequest):
                self.receievedRequestsFromFriends = receivedFriendRequest
                
                self.manager.fetchFriendRequests(type: .sent) { result in
                    switch result {
                    case .success(let sentFriendRequests):
                        self.sentRequestsToFriends = sentFriendRequests
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
