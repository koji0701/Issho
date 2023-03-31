//
//  UserDownloader.swift
//  Issho-New
//
//  Created by Koji Wong on 3/31/23.
//

import Foundation
import FirebaseFirestore

var cachedUsers = [String: UserInfo]()

class UserDownloader {
    let db = Firestore.firestore()
    
    
    func downloadUsers(uidsToSearch: [String], completion: @escaping ([UserInfo], Error?) -> Void) {
        
        var userArray = [UserInfo]()
        var uidsToDownload = [String]()
        
        for uid in uidsToSearch {
            if let cachedUser = cachedUsers[uid] {
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
                      print("snapshot documents = querysnapshot? documents")
                      for doc in snapshotDocuments {
                          
                          print("found one doc")
                          let data = doc.data()
                          
                          
                          if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String] {
                              print("got past the if let conditions")
                              
                              let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image, "todaysLikes": todaysLikes]
                              
                              
                              let user = UserInfo(uid: doc.documentID, dictionary: dict)
                              userArray.append(user)
                              cachedUsers["user.uid"] = user
                              
                          }
                      }
                      completion(userArray, nil)
                  }
              }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func downloadUsers(for userUID: String = User.shared().uid, whereField: String, completion: @escaping ([UserInfo], Error) -> Void) {
        
        db.collection(Constants.FBase.collectionName).whereField(whereField, arrayContains: userUID).getDocuments() { querySnapshot, error in
                
            
        }
    }
    
    private func reusableDownloading(querySnapshot: QuerySnapshot?, error: Error?) {
        if let e = error {
            print("There was an issue retrieving data from Firestore. \(e)")
        }
        else {
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    
                    if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendReq = data["friendRequests"], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String], let streakIsLate = data["streakIsLate"] as? Bool {
                        print("got past the if let conditions")
                        let isLiked = likes.contains(User.shared().uid)//if likes contains uid, true its been liked
                        let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "isLiked": isLiked, "friends": friends, "friendRequests": friendReq, "image": image, "likes": likes, "todaysLikes": todaysLikes, "streakIsLate": streakIsLate]
                        
                        
                        let newUser = UserInfo(uid: doc.documentID, dictionary: dict)
                        
                    }
                }
            }
        }
    }
    
    
}
