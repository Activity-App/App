//
//  UserController.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation

class UserController: ObservableObject {
    
    // MARK: Properties
    
    private let cloudKitStore: CloudKitStore
    
    private var userRecord: UserRecord?
    
    @Published var state = State.loading
    
    @Published var isSyncing = false
    
    // MARK: Init
    
    init(cloudKitStore: CloudKitStore = .shared) {
        self.cloudKitStore = cloudKitStore
    }
    
    // MARK: Methods
    
    /// Asynchronously updates the state with new data from the server.
    func updateData() {
        DispatchQueue.main.async {
            self.state = .loading
            self.isSyncing = true
        }
        cloudKitStore.fetchUserRecord { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSyncing = false
                switch result {
                case .success(let record):
                    self.userRecord = record
                    self.updateStateToMatchUserRecord()
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }
    
    /// Asynchronously updates the users nickname.
    /// - Parameter nickname: The new nickname.
    func setNickname(_ nickname: String) {
        guard let userRecord = userRecord else { return }
        userRecord.nickname = nickname
        
        updateStateToMatchUserRecord()
        syncRecord()
    }
    
    // MARK: Private Methods
    
    private func updateStateToMatchUserRecord() {
        guard let record = userRecord else { return }
        self.state = .user(.init(nickname: record.nickname, bio: record.bio))
    }
    
    private func syncRecord() {
        guard let userRecord = userRecord else { return }
        DispatchQueue.main.async {
            self.state = .loading
            self.isSyncing = true
        }
        cloudKitStore.saveUserRecord(userRecord, savePolicy: .changedKeys) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateData()
                case .failure(let error):
                    self.isSyncing = false
                    self.state = .failure(error)
                }
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
