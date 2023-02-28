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
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.setUpUser()
        }
        button.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
        
        navigationController?.navigationBar.backItem?.title = ""

    }
    
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    
    @IBOutlet weak var button: UIButton!
    
    /** different states of the button: Follow, Unfriend, Friends, Edit Profile, Accept Request, Request Sent **/
    
    private func setUpUser() {
        guard var user = user else {
            usernameLabel.text = User.shared().userInfo["username"] as? String
            friendsCountLabel.text = (User.shared().userInfo["friends"] as! [String]).count as? String
            streakLabel.text = User.shared().userInfo["streak"] as? String
            
            button.setTitle("Edit Profile", for: .normal)
            
            return
            
        }
        //set all the labels
        usernameLabel.text = user.username
        friendsCountLabel.text = String(user.friendsCount)
        streakLabel.text = String(user.streak)
        
        
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
            
            // TODO: edit profile session, popup vc?
        }
    }
    
    
}

