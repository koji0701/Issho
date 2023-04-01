//
//  AddFriendsManager.swift
//  Issho-New
//
//  Created by Koji Wong on 3/31/23.
//

import Foundation
import FirebaseFirestore

struct AddFriendsManager {
    static func acceptRequest(aceptee uid: String) {
        Firestore.updateUserInfo(uid: uid, fields: [ "friends": FieldValue.arrayUnion([User.shared().uid])])
        UserDownloader.cachedUsers[uid]?.friends.append(User.shared().uid)
        
        Firestore.updateUserInfo(uid: User.shared().uid, fields: [
            "friendRequests": FieldValue.arrayRemove([uid]),
            "friends": FieldValue.arrayUnion([uid])
        ])
    }
    
    static func deleteRequest(rejectee uid: String) {
        Firestore.updateUserInfo(uid: User.shared().uid, fields: ["friendRequests": FieldValue.arrayRemove([uid])])
    }
    
    static func cancelFriendRequest(cancelledUser uid: String) {
        Firestore.updateUserInfo(uid: uid, fields: [
            "friendRequests": FieldValue.arrayRemove([User.shared().uid])
        ])
        UserDownloader.cachedUsers[uid]?.friendRequests.removeAll(where: {$0 == User.shared().uid})
    }
    
    static func addFriend(newFriend uid: String) {
        UserDownloader.cachedUsers[uid]?.friendRequests.append(User.shared().uid)
        Firestore.updateUserInfo(uid: uid, fields: [
            "friendRequests": FieldValue.arrayUnion([User.shared().uid])
        ])
    }
    
    static func unfriend(notFriend uid: String) {
        Firestore.updateUserInfo(uid: User.shared().uid, fields: ["friends": FieldValue.arrayRemove([uid])])
        Firestore.updateUserInfo(uid: uid, fields: [
            "friends": FieldValue.arrayRemove([User.shared().uid])
        ])
        
        UserDownloader.cachedUsers[uid]?.friends.removeAll(where: {$0 == User.shared().uid})
        
    }
}
