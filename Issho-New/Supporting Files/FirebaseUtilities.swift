//
//  FirebaseUtilities.swift
//  Issho-New
//
//  Created by Koji Wong on 1/6/23.
//

import Foundation
import FirebaseFirestore

fileprivate let db = Firestore.firestore()

extension Firestore {
    
    static func updateUserInfo(uid: String, fields: [String: Any]) {
        db.collection(Constants.FBase.collectionName).document(uid).updateData(fields) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    
    
    
    static func initializeUser(uid: String, username: String, image: String) {
        db.collection(Constants.FBase.collectionName).document(uid).setData([
            "username": username,
            "streak": 0,
            "progress": 0,
            "isWorking": false,
            "lastUpdated": 0,
            "friends": [String](),
            "likes": [String](),
            "friendRequests": [String](),
            "image": image,
            "todaysLikes": [String]()
            
        ])
        User.shared().initUserInfo()

    }
    
}
