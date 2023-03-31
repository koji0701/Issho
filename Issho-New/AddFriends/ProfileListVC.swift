//
//  ViewProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 3/22/23.
//

import Foundation
import UIKit
import FirebaseFirestore

class ProfileListVC: UIViewController {
    
    
    //MARK: accept the userInfoUpdated call in order to update the users shown here. can just compare old update to new update, no need for firestore
    
    @IBOutlet weak var tableView: UITableView!
    var displayMode: Int! //0 - likes, 1 - friends
    
    var likesDuplicatesCount = [String: Int]()
    
    let userDownloader = UserDownloader()

    
    var displayFriends = [UserInfo]()
    var friendsForUserUID: String = User.shared().uid
    
    var displayItems = [UserInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.addFriendsNibName, bundle: nil), forCellReuseIdentifier: Constants.SM.addFriendsReuseIdentifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""
        if (displayMode == 0) {
            fetchLikes()

            navigationItem.title = "Likes"
            print("display mode working")
        }
        else if (displayMode == 1) {
            navigationItem.title = "Friends"
            fetchFriends(for: friendsForUserUID)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userProfileVC = segue.destination as? UserProfileVC {
            userProfileVC.user = sender as? UserInfo
            print("userprofilevc user: ", userProfileVC.user)
        }
        
    }
    
    private func fetchFriends(for userUID: String = User.shared().uid) {
        let db = Firestore.firestore()
        db.collection(Constants.FBase.collectionName).whereField("friends", arrayContains: userUID).getDocuments() { querySnapshot, error in
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }
            else {
                self.displayFriends = []
                print("gets past the else statement)")
                if let snapshotDocuments = querySnapshot?.documents {
                    print("snapshot documents = querysnapshot? documents")
                    for doc in snapshotDocuments {
                        print("found one doc")
                        let data = doc.data()
                        print(data)
                        if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String] {
                            print("got past the if let conditions")
                            
                            let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image, "todaysLikes": todaysLikes]
                            
                            
                            let friendReq = UserInfo(uid: doc.documentID, dictionary: dict)
                            self.displayFriends.append(friendReq)
                            DispatchQueue.main.async {
                                self.displayItems = self.displayFriends
                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    private func fetchLikes() {
        guard let rawTodaysLikes = User.shared().userInfo["todaysLikes"] as? [String] else {return}
 
        // Create a set to remove duplicates and a dictionary to count duplicates
        var uniqueTodaysLikes = [String]()
        for userID in rawTodaysLikes {
            if uniqueTodaysLikes.contains(userID) {
                likesDuplicatesCount[userID, default: 1] += 1
            } else {
                uniqueTodaysLikes.append(userID)
            }
        }
        
        userDownloader.downloadUsers(uidsToSearch: uniqueTodaysLikes, completion: {userArray, error in
            if let error = error {
                print("error in the fetchLikes call for userDownloader", error)
                return
            }
            
            self.displayItems = userArray
            self.tableView.reloadData()
        })
        /*
        db.collection(Constants.FBase.collectionName)
          .whereField("__name__", in: uniqueTodaysLikes)
          .getDocuments() { (querySnapshot, error) in
            if let error = error {
              print("Error fetching documents in fetchLikes: \(error)")
              return
            }
              else {
                  self.displayLikes = []
                  if let snapshotDocuments = querySnapshot?.documents {
                      print("snapshot documents = querysnapshot? documents")
                      for doc in snapshotDocuments {
                          print("found one doc")
                          let data = doc.data()
                          
                          if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String] {
                              print("got past the if let conditions")
                              
                              let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image, "todaysLikes": todaysLikes]
                              
                              
                              let user = UserInfo(uid: doc.documentID, dictionary: dict)
                              self.displayLikes .append(user)
                              DispatchQueue.main.async {
                                  self.displayItems = self.displayLikes
                                  self.tableView.reloadData()
                                  //MARK: CONTINUE. LIKES IS WORKING, I JUST NEED TO IMPLMENT THE 2X THING
                              }
                          }
                      }
                  }
              }
            // Handle the query results
        }*/
    }
}


extension ProfileListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.addFriendsReuseIdentifier, for: indexPath) as! AddFriendsCell
        cell.addFriendsCellDelegate = self
        cell.profilePic.loadImage(urlString: displayItems[indexPath.row].image)
        
        if (displayMode == 0) {
            //if the displayItems[indexPath.row].uid is in the likesDuplicatesCount
            if (likesDuplicatesCount.contains(where: {$0.key == displayItems[indexPath.row].uid})) {
                
                let dispDup = likesDuplicatesCount[displayItems[indexPath.row].uid]!
                cell.usernameLabel.text = displayItems[indexPath.row].username + "  x\(dispDup)🎉"
            }
            else {
                cell.usernameLabel.text = displayItems[indexPath.row].username
            }
        }
        else {
            cell.usernameLabel.text = displayItems[indexPath.row].username
        }
        
        
        cell.setActionButton(for: displayItems[indexPath.row], uid: friendsForUserUID)
        
        
        
        return cell
    }
    
    
}

extension ProfileListVC: AddFriendsCellDelegate {
    func addPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
        new.append(displayItems[indexPath.row].uid)
        User.shared().updateUserInfo(newInfo: [
            "friendRequests": new
        ])
    }
    
    func unfriendPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        Firestore.updateUserInfo(uid: User.shared().uid, fields: [
            "friends": FieldValue.arrayRemove([displayItems[indexPath.row].uid])
        ])
        Firestore.updateUserInfo(uid: displayItems[indexPath.row].uid, fields: [
            "friends": FieldValue.arrayRemove([User.shared().uid])
        ])
    }
    
    func requestSentPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
        new.removeAll(where: {$0 == displayItems[indexPath.row].uid})
        User.shared().updateUserInfo(newInfo: [
            "friendRequests": new
        ])
    }
    
    
    func deleteRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        Firestore.updateUserInfo(uid: displayItems[indexPath.row].uid, fields: ["friendRequests": FieldValue.arrayRemove([User.shared().uid])])
        cell.requestsView.isHidden = true
        
        cell.actionButton.isHidden = false
        cell.actionButton.isEnabled = true
        cell.actionButton.setTitle("Add", for: .normal)
    }
    
    func acceptRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        cell.requestsView.isHidden = true
        
        cell.actionButton.isHidden = false
        cell.actionButton.isEnabled = true
        cell.actionButton.setTitle("Friends", for: .normal)
        let user = displayItems[indexPath.row]
        
        var new = User.shared().userInfo["friends"] as? [String] ?? []
        new.append(user.uid)
        User.shared().updateUserInfo(newInfo: [
            "friends": new
        ])
        Firestore.updateUserInfo(uid: user.uid, fields: [
            "friends": FieldValue.arrayUnion([User.shared().uid]),
            "friendRequests": FieldValue.arrayRemove([User.shared().uid])
        ])
    }
    
    func viewProfile(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        performSegue(withIdentifier: Constants.Segues.profileListToUserProfile, sender: displayItems[indexPath.row])
    }
}
