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
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var displayMode: Int! //0 - likes, 1 - friends
    
    var displayLikes = [UserInfo]()
    var likesDuplicatesCount = [String: Int]()

    
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
            if (displayLikes.isEmpty) {
                fetchLikes()
            }
            else {
                displayItems = displayLikes
                tableView.reloadData()
            }

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
                        if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"] {
                            print("got past the if let conditions")
                            
                            let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image]
                            
                            
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
        let db = Firestore.firestore()
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
                          
                          if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"] {
                              print("got past the if let conditions")
                              
                              let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image]
                              
                              
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
        }
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
                cell.usernameLabel.text = displayItems[indexPath.row].username + "  (\(dispDup)🎉)"
            }
            else {
                cell.usernameLabel.text = displayItems[indexPath.row].username
            }
        }
        else {
            cell.usernameLabel.text = displayItems[indexPath.row].username
        }
        
        
        //hide buttons
        cell.addButton.isHidden = true
        cell.addButton.isEnabled = false
        cell.requestsView.isHidden = true
        cell.acceptButton.isHidden = true
        cell.acceptButton.isEnabled = false
        cell.deleteButton.isHidden = true
        cell.deleteButton.isEnabled = false
        
        
        return cell
    }
    
    
}

extension ProfileListVC: AddFriendsCellDelegate {
    
    func deleteRequest(in cell: AddFriendsCell) {
        return
    }
    
    func acceptRequest(in cell: AddFriendsCell) {
        return
    }
    
    func viewProfile(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        performSegue(withIdentifier: Constants.Segues.profileListToUserProfile, sender: displayItems[indexPath.row])
    }
}
