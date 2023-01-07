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
    var isWorking: Bool
    var streak: Int
    var likesCount: Int
    //profile image?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        friendsCount = dictionary["friendsCount"] as? Int ?? 0
        progressPercentage = dictionary["progressPercentage"] as? Int ?? 0
        isWorking = dictionary["isWorking"] as? Bool ?? false
        streak = dictionary["streak"] as? Int ?? 0
        likesCount = dictionary["likesCount"] as? Int ?? 0
    }
    
    
}
