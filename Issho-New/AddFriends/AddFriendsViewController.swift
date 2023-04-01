//
//  AddFriendsViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 2/7/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class AddFriendsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var friendRequestsLabel: UILabel!
    var displayItems = [UserInfo]()
    
    var displayIsShowingRequests = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""
        fetchFriendRequests()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userProfileVC = segue.destination as? UserProfileVC {
            userProfileVC.user = sender as? UserInfo
            print("userprofilevc user: ", userProfileVC.user)
        }
    }
    
    
    private func fetchFriendRequests() {
        
        let userDownloader = UserDownloader()
        userDownloader.downloadUsers(uidsToSearch: User.shared().userInfo["friendRequests"] as! [String], completion: {userArray,error in
            
            if let e = error {
                print("error fetchFriendRequests", e)
                return
            }
            self.displayItems = userArray
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.displayIsShowingRequests = true

        })
        
        /*
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
                        
                        if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendRq = data["friendRequests"] as? [String], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String] {
                            print("got past the if let conditions")
                            
                            let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendRq, "likes": likes, "image": image, "todaysLikes": todaysLikes]
                            
                            
                            let friendReq = UserInfo(uid: doc.documentID, dictionary: dict)
                            self.requests.append(friendReq)
                            print("requests: ", self.requests)
                            DispatchQueue.main.async {
                                self.displayItems = self.requests

                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
                        
                    }
        }*/
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"),                                           object: nil)
        friendRequestsLabel.font = Constants.Fonts.friendRequestsLabelFont

        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.addFriendsNibName, bundle: nil), forCellReuseIdentifier: Constants.SM.addFriendsReuseIdentifier)
        
        searchBar.delegate = self
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)

    }
    @objc private func refresh() {
        if (displayIsShowingRequests) {
            User.shared().initUserInfo()
        }
        else {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func userUpdate(_ notification: Notification) {
        if (displayIsShowingRequests) {
            fetchFriendRequests()
        }
        else {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension AddFriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (displayItems.count == 0) {
            if (displayIsShowingRequests) {
                return "No requests"
            }
            else {
                if (searchBar.searchTextField.text != "") {
                    print("setting to no users found")
                    return "No users found"
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.addFriendsReuseIdentifier, for: indexPath) as! AddFriendsCell
        
        cell.addFriendsCellDelegate = self
        cell.profilePic.loadImage(urlString: displayItems[indexPath.row].image)
        cell.usernameLabel.text = displayItems[indexPath.row].username
        
        if (displayIsShowingRequests) {
            cell.actionButton.isEnabled = false
            cell.actionButton.isHidden = true
            
            cell.requestsView.isHidden = false
            cell.acceptButton.isHidden = false
            cell.acceptButton.isEnabled = true
            cell.deleteButton.isHidden = false
            cell.deleteButton.isEnabled = true
        }
        /*
        else if (displayItems[indexPath.row].friendRequests.contains(User.shared().uid)) {
            cell.actionButton.isEnabled = false
            cell.actionButton.isHidden = true
            
            cell.requestsView.isHidden = false
            cell.acceptButton.isHidden = false
            cell.acceptButton.isEnabled = true
            cell.deleteButton.isHidden = false
            cell.deleteButton.isEnabled = true
        }
        else {
            cell.actionButton.isEnabled = true
            cell.actionButton.isHidden = false
            
            cell.requestsView.isHidden = true
        }*/
        else {
            cell.setActionButton(for: displayItems[indexPath.row])
        }
        
        return cell
    }
}

extension AddFriendsViewController: AddFriendsCellDelegate {
    func addPressed(in cell: AddFriendsCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        /*
        var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
        new.append(displayItems[indexPath.row].uid)
        User.shared().updateUserInfo(newInfo: [
            "friendRequests": new
        ])*/
        
        AddFriendsManager.addFriend(newFriend: displayItems[indexPath.row].uid)
    }
    
    func unfriendPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        /*var new = User.shared().userInfo["friends"] as? [String] ?? []
        new.removeAll(where: {$0 == displayItems[indexPath.row].uid})
        User.shared().updateUserInfo(newInfo: [
            "friends": new
        ])*/
        
        AddFriendsManager.unfriend(notFriend: displayItems[indexPath.row].uid)
        
    }
    
    func requestSentPressed(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        /*
        var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
        new.removeAll(where: {$0 == displayItems[indexPath.row].uid})
        User.shared().updateUserInfo(newInfo: [
            "friendRequests": new
        ])*/
        AddFriendsManager.unfriend(notFriend: displayItems[indexPath.row].uid)

    }
    
    
    
    func deleteRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        // remove from the display
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
        //Firestore.updateUserInfo(uid: requests[indexPath.row].uid, fields: ["friendRequests": FieldValue.arrayRemove([User.shared().uid])])
        /*
        var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
        new.removeAll(where: {$0 == displayItems[indexPath.row].uid})
        User.shared().updateUserInfo(newInfo: [
            "friendRequests": new
        ])*/
        
        AddFriendsManager.deleteRequest(rejectee: displayItems[indexPath.row].uid)
        
        // remove from the array
        displayItems.remove(at: indexPath.row)
        tableView.endUpdates()
    }
    
    func acceptRequest(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        // remove from the display
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
        AddFriendsManager.acceptRequest(aceptee: displayItems[indexPath.row].uid)
        
        // remove from the array
        displayItems.remove(at: indexPath.row)

        tableView.endUpdates()
    }
    
    func viewProfile(in cell: AddFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        performSegue(withIdentifier: Constants.Segues.addFriendsToUserProfile, sender: UserDownloader.cachedUsers[displayItems[indexPath.row].uid])
    }
    
    
}

extension AddFriendsViewController: UISearchBarDelegate {
    /* TODO:
     - when the search bar is clicked, clear display var and clear the tableview
     - when search bar is off clicked, or enter clicked, then load tableview with results
     - when search bar off clicked + blank or cancel button clicked, reload in the requests that were fetched. just save it into a variable so that theres a var for requests and a var for the tableview display
      - just use the wherefield query for firestore
     */
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (displayIsShowingRequests) {
            displayItems = [UserInfo]()
            displayIsShowingRequests = false
            tableView.reloadData()
        }
        searchBar.showsCancelButton = true
        friendRequestsLabel.isHidden = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchSearchResults(name: searchBar.text ?? "")
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            fetchSearchResults(name: searchBar.text ?? "")
            print("enter key clicked, should resign keyboard")
            searchBar.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .symbols) {

            if searchText.isEmpty {
                // Search text is empty
                fetchFriendRequests()
                
                
                searchBar.text = ""
                searchBar.showsCancelButton = false
                friendRequestsLabel.isHidden = false
            }
        }
        
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchFriendRequests()
        
        
        searchBar.text = ""
    }
    
    
    //search function
    private func fetchSearchResults(name: String) {
        if (name.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .symbols).isEmpty) {
            fetchFriendRequests()
            searchBar.text = ""
            return
        }
        
        let db = Firestore.firestore()
        db.collection(Constants.FBase.collectionName)
            .whereField("username", isGreaterThanOrEqualTo: name)
            .whereField("username", isLessThanOrEqualTo: name + "\u{f8ff}")
            .whereField("username", isNotEqualTo: User.shared().userInfo["username"] as! String)
            .limit(to: 4).getDocuments()
        { querySnapshot, error in
            self.displayItems = []
            print("found some usernames, found some documents")
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        
                        if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendReq = data["friendRequests"], let image = data["image"], let todaysLikes = data["todaysLikes"] as? [String] {
                            print("got past the if let conditions")
                            
                            let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "friends": friends, "friendRequests": friendReq, "likes": likes, "image": image, "todaysLikes": todaysLikes]
                            
                            let newPerson = UserInfo(uid: doc.documentID, dictionary: dict)
                            self.displayItems.append(newPerson)
                            UserDownloader.cachedUsers[doc.documentID] = newPerson
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
