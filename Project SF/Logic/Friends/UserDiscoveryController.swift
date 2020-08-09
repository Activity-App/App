//
//  UserDiscoveryController.swift
//  Project SF
//
//  Created by Christian Privitelli on 5/8/20.
//

import Foundation

class UserDiscoveryController: ObservableObject {
    
    var manager = UserDiscoveryManager()
    @Published var discovered: [User] = []
    
    init() {
        manager.fetchAllPublicUsers { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.discovered = users
                }
            case .failure(let error):
                print("discovery error \(error)")
            }
        }
    }
}
