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
    
    @IBOutlet weak var controlButton: FriendsControlButton!
    var friendStatusChanged: Bool = false
    
    /** different states of the button: Add, Unfriend, Friends, Add Friends, Accept Requested **/
    
    
    
    
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    @IBAction func settingsClicked(_ sender: Any) {
        print("settings clicked")
        performSegue(withIdentifier: Constants.Segues.profileToSettings, sender: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.setUpUser(completion: { showBadge in
                if (showBadge == true) {
                    let friendReqs = User.shared().userInfo["friendRequests"] as? [String] ?? []
                    if (friendReqs.count > 0) {
                        self.controlButton.addBadge(number: friendReqs.count)
                    }
                }
            })
        }
        controlButton.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        if let customTB = tabBarController as? CustomTabBarController {
            customTB.toggle(hide: false)
        }
        
        

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
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .medium)
        let normal = UIImage(systemName: "gearshape")?.withConfiguration(symbolConfig)
        let pressed = UIImage(systemName: "gearshape.fill")?.withConfiguration(symbolConfig)
        settingsButton.setImage(normal, for: .normal)
        settingsButton.setImage(pressed, for: .selected)
        settingsButton.tintColor = .label
        settingsButton.imageView?.tintColor = .label
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)
        
    }
    
    @objc private func userUpdate(_ notification: Notification) {
        
        if (user != nil) {
            if (User.shared().uid != user.uid) {
                return
            }
        }
        user = notification.object as? UserInfo
        
        
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
    
    private func setUpUser(completion: @escaping (Bool) -> Void) {
        
        guard var user = user else {
            controlButton.removeBadge()
            controlButton.setState(state: .addFriends)
            let username = User.shared().userInfo["username"] as? String ?? "Username"
            let streak = User.shared().userInfo["streak"] as? Int ?? 0
            let likes = User.shared().userInfo["todaysLikes"] as? [String] ?? [String]()
            let streakIsLate = User.shared().userInfo["streakIsLate"] as? Bool ?? false
            let friendRequests = User.shared().userInfo["friendRequests"] as? [String] ?? []
            likesLabel.text = " \(likes.count)🎉"
            streakLabel.text = "| \(streak)🔥"
            if (streakIsLate == true) {
                streakLabel.text! += "⏳"
            }
            usernameLabel.text = username
            friendsLabel.text = String((User.shared().userInfo["friends"] as? [String])?.count ?? 0) + " friends "
            
            profilePicImage.loadImage(urlString: User.shared().userInfo["image"] as? String ?? "default")
            
            settingsButton.isHidden = false
            
            completion(true)
            return
            
        }

        controlButton.removeBadge()
        
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
            controlButton.setState(state: .friends)
        }
        else if (user.friendRequests.contains(User.shared().uid)) {
            controlButton.setState(state: .requested)
        }
        else if ((User.shared().userInfo["friendRequests"] as? [String] ?? [String]()).contains(user.uid)) {
            controlButton.setState(state: .accept)
        }
        else if (user.uid == User.shared().uid) {
            controlButton.setState(state: .addFriends)
            completion(true)
            //also set up the badge if necessary
            
            
        }
        else {
            controlButton.setState(state: .add)
        }
        
        completion(false)
        
    }
    
    @IBAction func controlButtonClicked(_ sender: Any) {
        controlButton.updateState()
        friendStatusChanged = true
        if (controlButton.currentTitle == "Add") {
            
            AddFriendsManager.addFriend(newFriend: user.uid)
            
        }
        
        else if (controlButton.currentTitle == "Accept") {
            
            AddFriendsManager.acceptRequest(aceptee: user.uid)
            
        }
        
        else if (controlButton.currentTitle == "Requested") {
            
            AddFriendsManager.cancelFriendRequest(cancelledUser: user.uid)
        }
        
        else if (controlButton.currentTitle == "Friends") {
            
        }
        
        else if (controlButton.currentTitle == "Unfriend") {
            AddFriendsManager.unfriend(notFriend: user.uid)

            
        }
        
        else if (controlButton.currentTitle == "Add Friends") {
            print("add friends button clicked")
            performSegue(withIdentifier: Constants.Segues.profileToAddFriends, sender: nil)
            
        }
    }
    
    

    
    
    
}

