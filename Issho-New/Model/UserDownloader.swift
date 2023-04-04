//
//  UserDownloader.swift
//  Issho-New
//
//  Created by Koji Wong on 3/31/23.
//

import Foundation
import FirebaseFirestore


class UserDownloader {
    static var cachedUsers = [String: UserInfo]()

    let db = Firestore.firestore()
    
    
    func downloadUsers(uidsToSearch: [String], completion: @escaping ([UserInfo], Error?) -> Void) {
        
        var userArray = [UserInfo]()
        var uidsToDownload = [String]()
        
        for uid in uidsToSearch {
            if let cachedUser = UserDownloader.cachedUsers[uid] {
                userArray.append(cachedUser)
                print("found in cache")
            }
            else {
                uidsToDownload.append(uid)
                print("cache miss")
            }
        }
        if (uidsToDownload.count == 0) {
            completion(userArray, nil)
            return
        }
        
        db.collection(Constants.FBase.collectionName)
          .whereField("__name__", in: uidsToDownload)
          .getDocuments() { (querySnapshot, error) in
            if let e = error {
                print("Error fetching documents in fetchLikes: \(e)")
                completion(userArray, e)
              return
            }
              else {
                  if let snapshotDocuments = querySnapshot?.documents {
                      for doc in snapshotDocuments {
                          
                          let data = doc.data()
                          
                          
                          if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String], let streakIsLate = data["streakIsLate"], let hasFinishedToday = data["hasFinishedToday"] {
                              
                              let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image, "todaysLikes": todaysLikes, "streakIsLate": streakIsLate, "hasFinishedToday": hasFinishedToday]
                              
                              
                              let user = UserInfo(uid: doc.documentID, dictionary: dict)
                              userArray.append(user)
                              UserDownloader.cachedUsers[user.uid] = user
                              
                          }
                      }
                      completion(userArray, nil)
                  }
              }
            
        }
    }
    
    
}
