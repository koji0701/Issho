//
//  User.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth



class User {
    
    private static var userManager: User = {
        let user = User()
        //user.initUserInfo()
        return user
    }()
    
    
    
    private let db = Firestore.firestore()
    private var dbUpdateTimer: Timer?
    
    var uid: String = ""
    var userInfo = [String: Any]()
    private var lastUpdateUserInfo = [String: Any]()
    
    
    
    
    //accessor
    class func shared() -> User {
        return userManager
    }
    
    func initUserInfo() {
        guard let uID = Auth.auth().currentUser?.uid else {return}
        
        let docRef = db.collection(Constants.FBase.collectionName).document(uID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("was able to read document data")
                self.uid = uID
                /**
                self.username = document["username"] as! String
                self.progress = document["progress"] as! Float
                self.isWorking = document["isWorking"] as! Bool
                self.streak = document["streak"] as! Int
                self.likesCount = document["likesCount"] as! Int
                self.friendRequests = document["friendRequests"] as! [String]
                self.friends = document["friends"] as! [String]**/
                
                self.userInfo = [
                    "username": document["username"] as! String,
                    "progress": document["progress"] as! Float,
                    "isWorking": document["isWorking"] as! Bool,
                    "streak": document["streak"] as! Int,
                    "likesCount": document["likesCount"] as! Int,
                    "friendRequests": document["friendRequests"] as! [String],
                    "friends": document["friends"] as! [String]
                ]
                self.lastUpdateUserInfo = self.userInfo
                print("user info in the init", self.userInfo)
                NotificationCenter.default.post(name: NSNotification.Name("userInfoUpdated"),
                                                object: self.userInfo)
            } else {
                print("Document does not exist")
                fatalError("could not read user document, readUserDocument")
            }
        }
    }
    
    func updateUserInfo(newInfo: [String: Any]) {
        print("update user info call, previous userInfo", userInfo)
        
        dbUpdateTimer?.invalidate()//invalidate the timer if it is already running

        
        userInfo = [
            "username": newInfo["username"] as? String ?? userInfo["username"]!,
            "progress": newInfo["progress"] as? Float ?? userInfo["progress"]!,
            "isWorking": newInfo["isWorking"] as? Bool ?? userInfo["isWorking"]!,
            "streak": newInfo["streak"] as? Int ?? userInfo["streak"]!,
            "likesCount": newInfo["likesCount"] as? Int ?? userInfo["likesCount"]!,
            "friendRequests": newInfo["friendRequests"] as? [String] ?? userInfo["friendRequests"]!,
            "friends": newInfo["friends"] as? [String] ?? userInfo["friends"]!
        ]
        
        dbUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else {return}
            print("dbUpdateTimer is running")
            
            //if the previous update of userinfo is not equal to the current userinfo
            if !(NSDictionary(dictionary: self.userInfo).isEqual(to: self.lastUpdateUserInfo)) {
                self.lastUpdateUserInfo = self.userInfo//set the last update to current userinfo
                //push the update to firestoer
                Firestore.updateUserInfo(uid: self.uid, fields: self.userInfo)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("userInfoUpdated"),
                                            object: self.userInfo)
        }
        
        
        
    }
    
    
    
}
