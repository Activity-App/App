//
//  AppDelegate.swift
//  Project SF
//
//  Created by Christian Privitelli on 27/7/20.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print(userInfo)
        completionHandler(.newData)
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
