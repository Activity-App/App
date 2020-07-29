//
//  NotificationManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import CloudKit
import UIKit
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
    }
    
    func requestPermission(completion: @escaping (NotificationManagerError?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                completion(.other(error))
            }
            if success {
                completion(nil)
            } else {
                completion(.declined)
            }
        }
    }
    
    private func setupCategories() {
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_ACTION",
            title: "Accept",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        let ignoreAction = UNNotificationAction(
            identifier: "IGNORE_ACTION",
            title: "Ignore",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        let newFriendRequestCategory = UNNotificationCategory(
            identifier: "FRIEND_REQUEST",
            actions: [acceptAction, ignoreAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([newFriendRequestCategory])
    }
    
    func send(_ notification: UNNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let friendRequestRecordName = userInfo["FRIEND_REQUEST_RECORD_NAME"] as? String ?? ""
        
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            let friendRequestRecordID = CKRecord.ID(recordName: friendRequestRecordName)
            CloudKitStore.shared.fetchRecord(with: friendRequestRecordID, scope: .public) { result in
                switch result {
                case .success(let record):
                    FriendsManager().acceptFriendRequest(invitation: FriendRequestRecord(record: record)) { _ in
                        completionHandler()
                    }
                case .failure(let error):
                    print(error)
                    completionHandler()
                }
            }
        case "IGNORE_ACTION":
            UIApplication.shared.applicationIconBadgeNumber -= 1
            completionHandler()
        default:
            completionHandler()
        }
    }
    
    enum NotificationManagerError: Error {
        case declined
        case other(Error)
    }
}
