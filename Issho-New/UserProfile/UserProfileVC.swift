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
    @IBOutlet weak var friendsLabel: UILabel!
    
    @IBOutlet weak var profilePicImage: CustomImageView!
    
    @IBOutlet weak var streakLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var friendStatusChanged: Bool = false
    
    /** different states of the button: Add, Unfriend, Friends, Add Friends, Accept Request, Request Sent **/
    
    
    
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
    @IBAction func settingsClicked(_ sender: Any) {
        print("settings clicked")
        performSegue(withIdentifier: Constants.Segues.profileToSettings, sender: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.setUpUser()
        }
        button.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsLabel.isUserInteractionEnabled = true
        let friendsTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFriendsTap))
        friendsLabel.addGestureRecognizer(friendsTapGesture)
        
        usernameLabel.font = Constants.Fonts.userProfileUsernameFont
        friendsLabel.font = Constants.Fonts.userProfileAttributesFonts
        streakLabel.font = Constants.Fonts.userProfileAttributesFonts
        likesLabel.font = Constants.Fonts.userProfileAttributesFonts
    }
    
    @objc private func handleFriendsTap() {
        performSegue(withIdentifier: Constants.Segues.userProfileToProfileList, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileListVC = segue.destination as? ProfileListVC {
            profileListVC.displayMode = 1
            guard let user = user else {
                profileListVC.friendsForUserUID  = User.shared().uid
                return
            }
            profileListVC.friendsForUserUID = user.uid
            
        }
        
    }
    
    private func setUpUser() {
        
        guard var user = user else {
            let username = User.shared().userInfo["username"] as? String ?? "Username"
            let streak = User.shared().userInfo["streak"] as? Int ?? 0
            let likes = User.shared().userInfo["todaysLikes"] as? [String] ?? [String]()
            let streakIsLate = User.shared().userInfo["streakIsLate"] as? Bool ?? false
            likesLabel.text = " \(likes.count)🎉"
            streakLabel.text = "• \(streak)🔥"
            if (streakIsLate == true) {
                streakLabel.text! += "⏳"
            }
            usernameLabel.text = username
            friendsLabel.text = String((User.shared().userInfo["friends"] as? [String])?.count ?? 0) + " friends "
            
            profilePicImage.loadImage(urlString: User.shared().userInfo["image"] as! String)
            
            button.setTitle("Add Friends", for: .normal)
            
            
            settingsButton.isHidden = false
            return
            
        }

        button.removeBadge()
        
        profilePicImage.loadImage(urlString: user.image)
        
        //set all the labels
        likesLabel.text = "  \(user.todaysLikes.count)🎉"
        usernameLabel.text = user.username
        streakLabel.text = " • \(user.streak)🔥"
        if (user.streakIsLate == true) {
            streakLabel.text! += "⏳"
        }
        friendsLabel.text = String(user.friendsCount) + " friends"
        
        settingsButton.isHidden = true
        if (user.friends.contains(User.shared().uid)) {
            button.setTitle("Friends", for: .normal)

        }
        else if (user.friendRequests.contains(User.shared().uid)) {
            button.setTitle("Request Sent", for: .normal)
        }
        else if ((User.shared().userInfo["friendRequests"] as! [String]).contains(user.uid)) {
            button.setTitle("Accept Request", for: .normal)
        }
        else if (user.uid == User.shared().uid) {
            button.setTitle("Add Friends", for: .normal)
            
            //also set up the badge if necessary
            let friendReqs = User.shared().userInfo["friendRequests"] as! [String]
            
            if (friendReqs.count > 0) {
                button.addBadge(number: friendReqs.count)
            }
        }
        else {
            print("making it add")
            button.setTitle("Add", for: .normal)
        }
    }
    
    
    
    @IBAction func buttonClicked(_ sender: Any) {
        print("button clicked", button.currentTitle)
        
        friendStatusChanged = true
        if (button.currentTitle == "Add") {
            button.setTitle("Request Sent", for: .normal)
            
            AddFriendsManager.addFriend(newFriend: user.uid)
            
        }
        
        else if (button.currentTitle == "Accept Request") {
            button.setTitle("Friends", for: .normal)
            
            AddFriendsManager.acceptRequest(aceptee: user.uid)
            
        }
        
        else if (button.currentTitle == "Request Sent") {
            button.setTitle("Add", for: .normal)
            
            AddFriendsManager.cancelFriendRequest(cancelledUser: user.uid)
        }
        
        else if (button.currentTitle == "Friends") {
            button.setTitle("Unfriend", for: .normal)
            
        }
        
        else if (button.currentTitle == "Unfriend") {
            button.setTitle("Add", for: .normal)
            AddFriendsManager.unfriend(notFriend: user.uid)

            
        }
        
        else if (button.currentTitle == "Add Friends") {
            print("add friends button clicked")
            performSegue(withIdentifier: Constants.Segues.profileToAddFriends, sender: nil)
            
        }
    }
    
    
    
}

