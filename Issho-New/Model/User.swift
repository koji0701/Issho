//
//  User.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit



class User {
    
    private static var userManager: User = {
        let user = User()
        //user.initUserInfo()
        return user
    }()
    
    private let db = Firestore.firestore()
    private var dbUpdateTimer: Timer?
    
    var uid: String = ""
    var image: CustomImageView = CustomImageView()
    var userInfo = [String: Any]()
    private var updateInfo = [String: Any]()
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
                
                
                self.userInfo = [
                    "username": document["username"] as! String,
                    "progress": document["progress"] as! Float,
                    "isWorking": document["isWorking"] as! Bool,
                    "streak": document["streak"] as! Int,
                    "likes": document["likes"] as! [String],
                    "friendRequests": document["friendRequests"] as! [String],
                    "friends": document["friends"] as! [String],
                    "lastUpdated": document["lastUpdated"] as? Date ?? Date(),
                    "image": document["image"] as? String ?? "default",
                    "todaysLikes": document["todaysLikes"] as! [String],
                    "streakIsLate": document["streakIsLate"] as! Bool,
                    "hasFinishedToday":document["hasFinishedToday"] as! Bool

                ]
                self.lastUpdateUserInfo = self.userInfo
                self.image.loadImage(urlString: self.userInfo["image"] as! String)
                
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
        
        if let newImage = newInfo["image"] as? String {
            if newImage != (userInfo["image"] as! String) {
                image.loadImage(urlString: newImage)
            }
        }
        
        userInfo = [
            "username": newInfo["username"] as? String ?? userInfo["username"] ?? lastUpdateUserInfo["username"] ?? "",
            "progress": newInfo["progress"] as? Float ?? userInfo["progress"]!,
            "isWorking": newInfo["isWorking"] as? Bool ?? userInfo["isWorking"]!,
            "streak": newInfo["streak"] as? Int ?? userInfo["streak"]!,
            "likes": newInfo["likes"] as? Int ?? userInfo["likes"]!,
            "friendRequests": newInfo["friendRequests"] as? [String] ?? userInfo["friendRequests"]!,
            "friends": newInfo["friends"] as? [String] ?? userInfo["friends"]!,
            "lastUpdated": newInfo["lastUpdated"] as? [String] ?? userInfo["lastUpdated"]!,
            "image": newInfo["image"] as? String ?? userInfo["image"] ?? lastUpdateUserInfo["image"]!,
            "todaysLikes": newInfo["todaysLikes"] as? [String] ?? userInfo["todaysLikes"]!,
            "streakIsLate": newInfo["streakIsLate"] as? Bool ?? userInfo["streakIsLate"]!,
            "hasFinishedToday": newInfo["hasFinishedToday"] as? Bool ?? userInfo["hasFinishedToday"]!
            
        ]
        
        for (key, value) in newInfo {
            updateInfo[key] = value
        }
        NotificationCenter.default.post(name: NSNotification.Name("userInfoUpdated"),
                                        object: UserInfo(dictionary: self.userInfo))
        dbUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else {return}
            print("dbUpdateTimer is running")
            
            //if the previous update of userinfo is not equal to the current userinfo
            if !(NSDictionary(dictionary: self.userInfo).isEqual(to: self.lastUpdateUserInfo)) {
                print("pushing updates to firestore")
                self.lastUpdateUserInfo = self.userInfo//set the last update to current userinfo
                //push the update to firestoer
                Firestore.updateUserInfo(uid: self.uid, fields: self.updateInfo)
                
            }
            
            
        }
    }
    
    
    
    
    
}
