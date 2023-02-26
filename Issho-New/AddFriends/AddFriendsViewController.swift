//
//  AddFriendsViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 2/7/23.
//

import Foundation
import UIKit
import FirebaseFirestore

class AddFriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [UserInfo]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userProfileVC = segue.destination as? UserProfileVC {
            userProfileVC.user = sender as! UserInfo
        }
    }
    
    
    private func fetchFriendRequests() {
        let db = Firestore.firestore()
        db.collection(Constants.FBase.collectionName).whereField("friendRequests", arrayContains: User.shared().uid).getDocuments() { querySnapshot, error in
            self.requests = []
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }
            else {
                
                print("gets past the else statement)")
                if let snapshotDocuments = querySnapshot?.documents {
                    print("snapshot documents = querysnapshot? documents")
                    for doc in snapshotDocuments {
                        print("found one doc")
                        let data = doc.data()
                        
                        if let likesCount = data["likesCount"] as? Int, let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String] {
                            print("got past the if let conditions")
                            let isLiked = likes.contains(User.shared().uid)//if likes contains uid, true its been liked
                            let dict: [String: Any] = ["likesCount": likesCount, "streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "isLiked": isLiked, "friends": friends]
                            
                            
                            let friendReq = UserInfo(uid: doc.documentID, dictionary: dict)
                            self.requests.append(friendReq)
                            print("requests: ", self.requests)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
                        
                    }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"),                                           object: nil)
        
        fetchFriendRequests()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.addFriendsNibName, bundle: nil), forCellReuseIdentifier: Constants.SM.addFriendsReuseIdentifier)
    }
}

extension AddFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.addFriendsReuseIdentifier, for: indexPath) as! AddFriendsCell
        cell.addFriendsCellDelegate = self
        cell.usernameButton.setTitle(requests[indexPath.row].username, for: .normal)
        
        return cell
    }
}

extension AddFriendsViewController: AddFriendsCellDelegate {
    func deleteRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        // remove from the display
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
        // remove from the other user's outgoing friend requests
        Firestore.updateUserInfo(uid: requests[indexPath.row].uid, fields: ["friendRequests": FieldValue.arrayRemove([User.shared().uid])])
        
        // remove from the array
        requests.remove(at: indexPath.row)
        
        tableView.endUpdates()
    }
    
    func acceptRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        // remove from the display
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
        // remove from the other user's outgoing friend requests + add it to both user's friends list
        Firestore.updateUserInfo(uid: requests[indexPath.row].uid, fields: ["friendRequests": FieldValue.arrayRemove([User.shared().uid]), "friends": FieldValue.arrayUnion([User.shared().uid])])
        User.shared().updateUserInfo(newInfo: ["friends": FieldValue.arrayUnion([requests[indexPath.row].uid])])
        
        // remove from the array
        requests.remove(at: indexPath.row)
        
        tableView.endUpdates()
    }
    
    func viewProfile(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        performSegue(withIdentifier: Constants.Segues.addFriendsToUserProfile, sender: requests[indexPath.row])
    }
    
    
}

