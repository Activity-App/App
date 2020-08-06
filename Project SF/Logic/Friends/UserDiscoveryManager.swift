//
//  UserDiscoveryManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 5/8/20.
//

import Foundation

class UserDiscoveryManager {
    
    let cloudKitStore = CloudKitStore.shared
    
    func fetchAllPublicUsers(then handler: @escaping (Result<[User], CloudKitStoreError>) -> Void) {
        cloudKitStore.fetchRecords(with: PublicUserRecord.self, scope: .public) { result in
            switch result {
            case .success(let records):
                let returnVal = records.compactMap { User(publicUserRecord: $0) }
                handler(.success(returnVal))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
