//
//  UserController.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation
import CloudKit

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
        updateData(setStateToLoading: true)
    }
    
    /// Asynchronously updates the users details.
    /// - Parameter name: The new name.
    /// - Parameter username: The new username.
    /// - Parameter bio: The new bio.
    func set(name: String? = nil, username: String? = nil, bio: String? = nil) {
        guard let userRecord = userRecord else { return }
        
        state = .loading
        
        if let name = name {
            userRecord.name = name
        }
        if let username = username {
            userRecord.username = username
        }
        if let bio = bio {
            userRecord.bio = bio
        }
        
        syncRecord()
    }
    
    // MARK: Private Methods
    
    private func updateStateToMatchUserRecord() {
        guard let record = userRecord else { return }
        self.state = .user(.init(name: record.name, username: record.username, bio: record.bio))
    }
    
    private func syncRecord() {
        guard let userRecord = userRecord else { return }
        DispatchQueue.main.async {
            self.isSyncing = true
        }
        cloudKitStore.saveUserRecord(userRecord, savePolicy: .changedKeys) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateData(setStateToLoading: false)
                case .failure(let error):
                    self.isSyncing = false
                    self.state = .failure(error)
                }
            }
        }
    }
    
    func updateData(setStateToLoading: Bool) {
        DispatchQueue.main.async {
            if setStateToLoading {
                self.state = .loading
            }
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
    
    // MARK: - State
    
    enum State: Equatable {
        case loading
        case user(UserViewModel)
        case failure(Error)
        
        /// Make equatable to detect changes.
        static func == (lhs: UserController.State, rhs: UserController.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loading, .user),
                 (.loading, .failure),
                 (.failure, .user),
                 (.user, .loading),
                 (.user, .failure),
                 (.failure, .loading):
                return false
            case (.user(let lhsUser), .user(let rhsUser)):
                if lhsUser == rhsUser {
                    return true
                } else {
                    return false
                }
            case (.failure(let lhsError), .failure(let rhsError)):
                if lhsError.localizedDescription == rhsError.localizedDescription {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    // MARK: - UserViewModel
    
    struct UserViewModel: Equatable {
        let name: String?
        let username: String?
        let bio: String?
    }
}
