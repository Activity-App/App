//
//  NotificationManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 26/7/20.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
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
    
    enum NotificationManagerError: Error {
        case declined
        case other(Error)
    }
}
