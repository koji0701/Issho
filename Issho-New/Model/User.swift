//
//  User.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import Foundation

struct User {
    let uid: String
    let username: String
    var friendsCount: Int
    var progress: Int
    var isActive: Bool
    var streak: Int
    //profile image?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        friendsCount = dictionary["friendsCount"] as? Int ?? 0
        progress = dictionary["progress"] as? Int ?? 0
        isActive = dictionary["isActive"] as? Bool ?? false
        streak = dictionary["streak"] as? Int ?? 0
    }
}
