//
//  AddFriendsCell.swift
//  Issho-New
//
//  Created by Koji Wong on 2/8/23.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol AddFriendsCellDelegate {
    
    func deleteRequest(in cell: AddFriendsCell)
    func acceptRequest(in cell: AddFriendsCell)
    
    func addPressed(in cell: AddFriendsCell)
    func unfriendPressed(in cell: AddFriendsCell)
    func requestSentPressed(in cell: AddFriendsCell)
    
    
    func viewProfile(in cell: AddFriendsCell)
}


class AddFriendsCell: UITableViewCell {
    
    var addFriendsCellDelegate: AddFriendsCellDelegate!

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profilePic: CustomImageView!
    @IBOutlet weak var profilePicTapView: UIView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var requestsView: UIView!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        addFriendsCellDelegate?.deleteRequest(in: self)
        print("delete button clicked")
    }
    
    
    @IBAction func acceptButtonClicked(_ sender: Any) {
        addFriendsCellDelegate?.acceptRequest(in: self)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.font = Constants.Fonts.profileListUsernameFont
        
        profilePic.image = profilePic.image?.resize(to: CGSize(width: profilePic.frame.width, height: profilePic.frame.height))
        usernameLabel.isUserInteractionEnabled = true
        let profilePicTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        let usernameTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        
        profilePicTapView.addGestureRecognizer(profilePicTapToSegue)
        usernameLabel
            .addGestureRecognizer(usernameTapToSegue)
    }
    
    @objc private func handleSegueAction(_ gestureRecognizer: UITapGestureRecognizer)
    {
        addFriendsCellDelegate?.viewProfile(in: self)
    }
    
    
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        if (actionButton.currentTitle == "Add") {
            addFriendsCellDelegate?.addPressed(in: self)
            
            actionButton.setTitle("Request Sent", for: .normal)
            
        }
        
        
        else if (actionButton.currentTitle == "Request Sent") {
            addFriendsCellDelegate?.requestSentPressed(in: self)
            
            
            actionButton.setTitle("Add", for: .normal)
            
        }
        
        else if (actionButton.currentTitle == "Friends") {
            actionButton.setTitle("Unfriend", for: .normal)
            
        }
        
        else if (actionButton.currentTitle == "Unfriend") {
            addFriendsCellDelegate?.unfriendPressed(in: self)
            
            actionButton.setTitle("Add", for: .normal)
            /*
            var new = User.shared().userInfo["friends"] as? [String] ?? []
            new.removeAll(where: {$0 == user.uid})
            User.shared().updateUserInfo(newInfo: [
                "friends": new
            ])*/
            
            
        }
    }
    
    func setActionButton(for user: UserInfo, uid: String = User.shared().uid) {
        requestsView.isHidden = true
        actionButton.isHidden = false
        actionButton.isEnabled = true
        if (user.friends.contains(User.shared().uid)) {
            //already friends
            actionButton.setTitle("Friends", for: .normal)
        }
        else if (user.friendRequests.contains(User.shared().uid)) {
            //accept/reject request
            actionButton.isHidden = true
            actionButton.isEnabled = false
            requestsView.isHidden = false
            acceptButton.isHidden = false
            deleteButton.isHidden = false
            acceptButton.isEnabled = true
            deleteButton.isEnabled = true
        }
        else if ((User.shared().userInfo["friendRequests"] as! [String]).contains(user.uid)) {
            //request sent
            actionButton.setTitle("Request Sent", for: .normal)
        }
        else if (user.uid == User.shared().uid) {
            //thats you!
            actionButton.setTitle("Thats you!", for: .normal)
            actionButton.isEnabled = false
            
        }
        else {
            //add button
            actionButton.setTitle("Add", for: .normal)
        }
    }
    
}
