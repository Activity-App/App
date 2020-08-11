//
//  FriendRequestStruct.swift
//  Project SF
//
//  Created by Christian Privitelli on 30/7/20.
//

import UIKit

struct FriendRequest: Identifiable {
    let id: String
    
    let recipientName: String?
    let creatorName: String?
    let recipientUsername: String?
    let creatorUsername: String?
    let recipientProfilePicture: UIImage?
    let creatorProfilePicture: UIImage?
    
    let record: FriendRequestRecord
}
