//
//  AppDelegate.swift
//  Project SF
//
//  Created by Christian Privitelli on 27/7/20.
//

import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let cloudKitStore: CloudKitStore = .shared
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print(userInfo)
        guard let ckInfo = userInfo["ck"] as? [String: Any] else { return }
        guard let queryInfo = ckInfo["qry"] as? [String: Any] else { return }
        let friendRequestRecordName = queryInfo["rid"] as? String ?? ""
        
        cloudKitStore.fetchRecord(with: CKRecord.ID(recordName: friendRequestRecordName), scope: .public) { result in
            switch result {
            case .success(let record):
                let friendRequestRecord = FriendRequestRecord(record: record)
                let publicDataRecordName = friendRequestRecord.creatorPublicUserRecordName ?? ""
                print(publicDataRecordName)
                self.cloudKitStore.fetchRecord(with: CKRecord.ID(recordName: publicDataRecordName), scope: .public) { result in
                    switch result {
                    case .success(let publicDataRecordRaw):
                        let publicDataRecord = PublicUserRecord(record: publicDataRecordRaw)
                        guard let username = publicDataRecord.username else { return }
                        let name = publicDataRecord.name

                        let notification = UNMutableNotificationContent()
                        notification.title = "New Friend Request"
                        notification.sound = UNNotificationSound.default
                        notification.userInfo = ["FRIEND_REQUEST_RECORD_NAME": friendRequestRecordName]
                        notification.categoryIdentifier = "FRIEND_REQUEST"
                        
                        if let name = name, name != "" {
                            notification.body = "\(name) sent you a friend request!"
                        } else {
                            notification.body = "New friend request from \(username)"
                        }
                        
                        NotificationManager.shared.send(notification)
                        
                        completionHandler(.newData)
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        // This is the data that is returned:
        /*
         [AnyHashable("aps"): {
             "content-available" = 1;
         }, AnyHashable("ck"): {
             ce = 2;
             cid = "iCloud.com.ChristianPrivitelli.ProjectSF";
             ckuserid = "_ca83d0962e8569057e2d4bece6c0a335";
             nid = "943172cd-822f-4890-8a2b-b24bb2a15527";
             qry =     {
                 dbs = 2;
                 fo = 1;
                 rid = "E3FB89A0-C59C-4825-BF3D-93BFADEC7626"; // this is the record of the user info. Important as we can query this and find username or name to show on the notification.
                 sid = "950997CC-0D04-408D-9EA9-B47047567919";
                 zid = "_defaultZone";
                 zoid = "_defaultOwner";
             };
         }]

        */
    }
}
