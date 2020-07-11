//
//  UserController.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation

class UserController: ObservableObject {
    
    // MARK: Properties
    
    let cloudKitStore: CloudKitStore
    
    @Published var state = State.loading
    
    // MARK: Init
    
    init(cloudKitStore: CloudKitStore = .shared) {
        self.cloudKitStore = cloudKitStore
    }
    
    // MARK: Methods
    
    func startLoading() {
        cloudKitStore.fetchUserRecord { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let record):
                self.state = .user(.init(nickname: record.nickname, bio: record.bio))
            case .failure(let error):
                self.state = .failure(error)
            }
        }
    }
    
    // MARK: - State
    
    enum State {
        case loading
        case user(UserViewModel)
        case failure(Error)
    }
    
    // MARK: - UserViewModel
    
    struct UserViewModel {
        
        let nickname: String?
        
        let bio: String?
        
    }
    
}
