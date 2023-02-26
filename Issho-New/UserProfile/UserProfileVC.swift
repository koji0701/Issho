//
//  UserProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 2/20/23.
//

import Foundation
import UIKit

class UserProfileVC: UIViewController {
    
    var user: UserInfo!
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpUser()
    }
    
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var acceptRequestButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    
    private func setUpUser() {
        guard let user = user else {
            usernameLabel.text = User.shared().userInfo["username"] as? String
            friendsCountLabel.text = User.shared().userInfo["friendsCount"] as? String
            streakLabel.text = User.shared().userInfo["streak"] as? String
            
            editProfileButton.isHidden = false
            editProfileButton.isEnabled = true
            
            
            followButton.isHidden = true
            followButton.isEnabled = false
            friendsButton.isHidden = true
            friendsButton.isEnabled = false
            acceptRequestButton.isHidden = true
            acceptRequestButton.isEnabled = false
            return
            
        }
        //set all the labels
        usernameLabel.text = user.username
        friendsCountLabel.text = String(user.friendsCount)
        streakLabel.text = String(user.streak)
        
        editProfileButton.isEnabled = false
        editProfileButton.isHidden = true
        
        
        //set the follow/unfollow button
        if (user.friends.contains(User.shared().uid)) {
            followButton.isHidden = true
            followButton.isEnabled = false
            
            friendsButton.isHidden = false
            friendsButton.isEnabled = true
            
            acceptRequestButton.isHidden = true
            acceptRequestButton.isEnabled = false
            
            
        }
        else if (user.friendRequests.contains(User.shared().uid)) {
            acceptRequestButton.isHidden = false
            acceptRequestButton.isEnabled = true
            
            followButton.isHidden = true
            followButton.isEnabled = false
            
            friendsButton.isHidden = true
            friendsButton.isEnabled = false
        }
        else {
            followButton.isHidden = false
            followButton.isEnabled = true
            friendsButton.isHidden = false
            friendsButton.isEnabled = true
            acceptRequestButton.isHidden = true
            acceptRequestButton.isEnabled = false
        }
    }
    
    // TODO: follow button functionality
    @IBAction func followButtonClicked(_ sender: Any) {
        if (followButton.currentTitle == "Follow") {
            followButton.setTitle("Request Sent", for: .normal)
            print("follow button clicked")
        }
    }
    
    // TODO: friends/unfollow button functionality
    @IBAction func friendsButtonClicked(_ sender: Any) {
        
    }
    
    
    // TODO: accept request button
    
    @IBAction func acceptRequestButtonClicked(_ sender: Any) {
        
    }
    // TODO: edit profile functionality
    
    @IBAction func editProfileButtonClicked(_ sender: Any) {
        
    }
    
}

