//
//  AddFriendsCell.swift
//  Issho-New
//
//  Created by Koji Wong on 2/8/23.
//

import Foundation
import UIKit


protocol AddFriendsCellDelegate {
    
    func deleteRequest(in cell: AddFriendsCell)
    func acceptRequest(in cell: AddFriendsCell)
    func viewProfile(in cell: AddFriendsCell)
}


class AddFriendsCell: UITableViewCell {
    
    var addFriendsCellDelegate: AddFriendsCellDelegate!

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profilePic: CustomImageView!
    @IBOutlet weak var profilePicTapView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    
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
    
}
