//
//  UserProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 2/20/23.
//

import Foundation
import UIKit
import FirebaseFirestore

class UserProfileVC: UIViewController {
    
    var user: UserInfo!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    
    
    @IBOutlet weak var streakLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    /** different states of the button: Follow, Unfriend, Friends, Edit Profile, Accept Request, Request Sent **/
    
    @IBAction func addFriendsClicked(_ sender: Any) {
        print("add friends clicked")
        performSegue(withIdentifier: Constants.Segues.profileToAddFriends, sender: nil)
    }
    
    
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var addFriendsButton: UIButton!
    
    
    @IBAction func settingsClicked(_ sender: Any) {
        print("settings clicked")
        performSegue(withIdentifier: Constants.Segues.profileToSettings, sender: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.setUpUser()
        }
        button.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        navigationController?.navigationBar.backItem?.title = ""

    }
    
    
    
    private func setUpUser() {
        guard var user = user else {
            let username = User.shared().userInfo["username"] as? String ?? "Username"
            let streak = User.shared().userInfo["streak"] as? String ?? "0"
            streakLabel.text = streak
            usernameLabel.text = username
            friendsCountLabel.text = String((User.shared().userInfo["friends"] as? [String])?.count ?? 0)
            
            
            button.setTitle("Edit Profile", for: .normal)
            
            
            addFriendsButton.isHidden = false
            settingsButton.isHidden = false
            return
            
        }
        //set all the labels
        usernameLabel.text = user.username
        streakLabel.text = "\(user.streak)"
        friendsCountLabel.text = String(user.friendsCount)
        
        addFriendsButton.isHidden = true
        settingsButton.isHidden = true
        if (user.friends.contains(User.shared().uid)) {
            button.setTitle("Friends", for: .normal)

        }
        else if (user.friendRequests.contains(User.shared().uid)) {
            button.setTitle("Accept Request", for: .normal)
        }
        else if ((User.shared().userInfo["friendRequests"] as! [String]).contains(user.uid)) {
            button.setTitle("Request Sent", for: .normal)
        }
        else if (user.uid == User.shared().uid) {
            button.setTitle("Edit Profile", for: .normal)
        }
        else {
            print("making it follow")
            button.setTitle("Follow", for: .normal)
        }
    }
    
    
    
    @IBAction func buttonClicked(_ sender: Any) {
        print("button clicked", button.currentTitle)
        if (button.currentTitle == "Follow") {
            button.setTitle("Request Sent", for: .normal)
            var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
            new.append(user.uid)
            User.shared().updateUserInfo(newInfo: [
                "friendRequests": new
            ])
        }
        
        else if (button.currentTitle == "Accept Request") {
            button.setTitle("Friends", for: .normal)
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
        
        else if (button.currentTitle == "Request Sent") {
            button.setTitle("Follow", for: .normal)
            
            var new = User.shared().userInfo["friendRequests"] as? [String] ?? []
            new.removeAll(where: {$0 == user.uid})
            User.shared().updateUserInfo(newInfo: [
                "friendRequests": new
            ])
        }
        
        else if (button.currentTitle == "Friends") {
            button.setTitle("Unfriend", for: .normal)
            
        }
        
        else if (button.currentTitle == "Unfriend") {
            button.setTitle("Follow", for: .normal)
            var new = User.shared().userInfo["friends"] as? [String] ?? []
            new.removeAll(where: {$0 == user.uid})
            User.shared().updateUserInfo(newInfo: [
                "friends": new
            ])
            Firestore.updateUserInfo(uid: user.uid, fields: [
                "friends": FieldValue.arrayRemove([User.shared().uid])
            ])
            
        }
        
        else if (button.currentTitle == "Edit Profile") {
            print("edit profile button clicked")
            
            
        }
    }
    
    
}

