//
//  Main.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation

@main
struct Main {
    
    static func main() {
        /*CompetitionsController().createCompetition(type: .move, endDate: Date().addingTimeInterval(10000),
                                                   friends: [Friend(name: "Will", profilePicture: nil, recordID: CKRecord.ID(recordName: "_f02a4946a7fa369e5f2692ef37a8637b"))]) { result in
            print(result)
        }*/
        CompetitionsController().fetchPendingInvitations { result in
            print(result)
            switch result {
            case .success(let invitations):
                for invitation in invitations {
                    CompetitionsController().acceptInvitation(invitation) { result in
                        print("Final Result: \(result)")
                    }
                }
            case .failure: break
            }
        }
        if !ProcessInfo.processInfo.isTesting {
            ProjectSFApp.main()
        } else {
            TestApp.main()
        }
    }
    
}
