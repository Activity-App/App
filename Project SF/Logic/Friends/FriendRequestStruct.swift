//
//  FriendRequestStruct.swift
//  Project SF
//
//  Created by Christian Privitelli on 30/7/20.
//

import UIKit

struct FriendRequest: Identifiable {
    let id: String
    let inviteeName: String?
    let creatorName: String?
    let inviteeUsername: String?
    let creatorUsername: String?
    let inviteeProfilePicture: UIImage?
    let creatorProfilePicture: UIImage?
    
    let record: FriendRequestRecord
}
