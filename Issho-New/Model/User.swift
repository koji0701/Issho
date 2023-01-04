//
//  User.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import Foundation

class User: Codable {
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
    
    /**static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        // 2
        if writeToUserDefaults {
            // 3
            if let data = try? JSONEncoder().encode(user) {
                // 4
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }

        _current = user
    }**/
}
