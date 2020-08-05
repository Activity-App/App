//
//  UserController.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import CloudKit

/// Handles the user of the application in CloudKit.
///
/// The UserRecord will be always saved to your private database with your information. If you choose, you can make your information public. This is done through the UserInfoRecord. Use the `set` method with `publicDb` to `true` to set new specified information to be exposed to the public db or`makeUserInfoPublic` to set all current info(name, bio, pfp) to the public db. Conversely, you can use `makeUserInfoPrivate` to remove all user info from the public db.
class UserController: ObservableObject {
    
    // MARK: Properties

    private let manager = UserManager.shared

    @Published var user: User?
    @Published var loading = false
    
    func setup(then handler: @escaping (CloudKitStoreError?) -> Void) {
        isLoading(true)
        manager.setup { result in
            switch result {
            case .success:
                self.update { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            handler(error)
                        }
                        handler(nil)
                    }
                }
            case .failure(let error):
                self.isLoading(false)
                handler(error)
            }
        }
    }
    
    func save(then handler: @escaping (CloudKitStoreError?) -> Void) {
        guard let user = user else { handler(.missingRecord); return }
        isLoading(true)
        manager.save(user: user) { result in
            self.isLoading(false)
            switch result {
            case .success:
                self.update { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            handler(error)
                            return
                        }
                        handler(nil)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    handler(error)
                }
            }
        }
    }
    
    func update(then handler: @escaping (CloudKitStoreError?) -> Void) {
        isLoading(true)
        manager.fetch { result in
            DispatchQueue.main.async {
                self.isLoading(false)
                switch result {
                case .success(let user):
                    self.user = user
                    handler(nil)
                case .failure(let error):
                    handler(error)
                }
            }
        }
    }
    
    private func isLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.loading = isLoading
        }
    }
}
