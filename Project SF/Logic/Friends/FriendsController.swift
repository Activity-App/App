//
//  FriendsController.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import Foundation

class FriendController: ObservableObject {
    
    @Published var friends: [Friend] = []
    @Published var discoveredFriends: [Friend] = []
    @Published var sentRequestsToFriends: [Friend] = []
    @Published var receievedRequestsFromFriends: [Friend] = []
    @Published var sharingEnabled = UserDefaults.standard.bool(forKey: "sharingEnabled")
    
}
