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

    
    var friendsForUserUID: String = User.shared().uid
    
    var displayItems = [UserInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.addFriendsNibName, bundle: nil), forCellReuseIdentifier: Constants.SM.addFriendsReuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)
        
    }
    
    @objc private func refresh() {
        User.shared().initUserInfo()
    }
    
    @objc private func userUpdate(_ notification: Notification) {
        if (displayMode == 0) {
            fetchLikes()
        }
        else if (displayMode == 1) {
            fetchFriends(for: friendsForUserUID)
        }
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
        let toSearch: [String]
        if (userUID == User.shared().uid) {
            toSearch = User.shared().userInfo["friends"] as! [String]
        }
        else {
            toSearch = UserDownloader.cachedUsers[userUID]?.friends ?? []
        }
        userDownloader.downloadUsers(uidsToSearch: toSearch, completion: { userArray, error in
            if let e = error {
                print("error in fetchFriends profilelistvc, ",e)
                return
                
            }
            self.tableView.refreshControl?.endRefreshing()
            self.displayItems = userArray
            self.tableView.reloadData()
        })
        
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
            self.tableView.refreshControl?.endRefreshing()
            self.displayItems = userArray
            self.tableView.reloadData()
        })
        
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
        AddFriendsManager.addFriend(newFriend: displayItems[indexPath.row].uid)

    }
    
    func unfriendPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        AddFriendsManager.unfriend(notFriend: displayItems[indexPath.row].uid)

    }
    
    func requestSentPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        AddFriendsManager.cancelFriendRequest(cancelledUser: displayItems[indexPath.row].uid)
    }
    
    
    func deleteRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        AddFriendsManager.deleteRequest(rejectee: displayItems[indexPath.row].uid)
        
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
        AddFriendsManager.acceptRequest(aceptee: displayItems[indexPath.row].uid)
        
    }
    
    func viewProfile(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        performSegue(withIdentifier: Constants.Segues.profileListToUserProfile, sender: UserDownloader.cachedUsers[displayItems[indexPath.row].uid])
    }
}
