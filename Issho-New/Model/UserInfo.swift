//
//  SM.swift
//  Issho
//
//  Created by Koji Wong on 11/10/22.
//

import Foundation

//https://firebase.google.com/docs/firestore/solutions/swift-codable-data-mapping post as codable?
struct UserInfo {
    let uid: String
    
    let isWorking: Bool
    let streak: Int
    let username: String
    let progress: Float
    let lastUpdated: Date
    var friendRequests: [String]
    var friends: [String]
    var likes: [String]
    var todaysLikes: [String]
    let image: String
    let streakIsLate: Bool
    let hasFinishedToday: Bool
    
    lazy var friendsCount: Int = friends.count
    
    lazy var isLiked: Bool = {
        if (uid == User.shared().uid) {
            return false
        }
        else {
            return likes.contains(User.shared().uid)
        }
        
    }()
    lazy var likesCount: Int = likes.count
    
    

    
    init(uid: String = User.shared().uid, dictionary: [String: Any]) {
        self.uid = uid
        
        isWorking = dictionary["isWorking"] as? Bool ?? false
        streak = dictionary["streak"] as? Int ?? 0
        username = dictionary["username"] as? String ?? "Name"
        progress = dictionary["progress"] as? Float ?? 0.0
        lastUpdated = dictionary["lastUpdated"] as? Date ?? Date()
        friendRequests = dictionary["friendRequests"] as? [String] ?? [String]()
        friends = dictionary["friends"] as? [String] ?? [String]()
        likes = dictionary["likes"] as? [String] ?? [String]()
        image = dictionary["image"] as? String ?? "default"
        todaysLikes = dictionary["todaysLikes"] as? [String] ?? [String]()
        streakIsLate = dictionary["streakIsLate"] as? Bool ?? false
        hasFinishedToday = dictionary["hasFinishedToday"] as? Bool ?? false
        
        
        likesCount = likes.count
        isLiked = {
            return likes.contains(User.shared().uid)
            
        }()
        friendsCount = friends.count
        
    }
    
    
}
