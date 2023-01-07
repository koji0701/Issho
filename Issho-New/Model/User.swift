//
//  User.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import Foundation

class User {
    let uid: String
    let username: String
    var friendsCount: Int
    var progressPercentage: Int
    var isActive: Bool
    var streak: Int
    var likes: Int
    //profile image?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        friendsCount = dictionary["friendsCount"] as? Int ?? 0
        progressPercentage = dictionary["progressPercentage"] as? Int ?? 0
        isActive = dictionary["isActive"] as? Bool ?? false
        streak = dictionary["streak"] as? Int ?? 0
        likes = dictionary["likes"] as? Int ?? 0
    }
    
    
}
