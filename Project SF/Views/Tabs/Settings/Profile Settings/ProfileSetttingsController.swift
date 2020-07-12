//
//  ProfileSetttingsController.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import Combine

class ProfileSettingsController: ObservableObject {
    
    // MARK: Properties
    
    let userController: UserController
    
    var stateChangeCancellable: AnyCancellable?
    
    @Published var nicknameText = ""
    
    @Published var bioText = ""
    
    // MARK: Init
    
    init(userController: UserController = .init()) {
        self.userController = userController
    }
    
    // MARK: Methods
    
    func setup() {
        stateChangeCancellable = userController.$state
            .sink { [weak self] newState in
                guard let self = self else { return }
                if case .user(let user) = newState {
                    self.nicknameText = user.nickname ?? ""
                    self.bioText = user.bio ?? ""
                }
            }
        userController.updateData()
    }
    
    func setNickname() {
        userController.setNickname(nicknameText)
    }
    
}
