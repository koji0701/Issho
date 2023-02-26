//
//  AddFriendsCell.swift
//  Issho-New
//
//  Created by Koji Wong on 2/8/23.
//

import Foundation
import UIKit

class AddFriendsCell: UITableViewCell {
    
    var addFriendsCellDelegate: AddFriendsCellDelegate!

    @IBOutlet weak var usernameButton: UIButton!
    
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        addFriendsCellDelegate?.deleteRequest(in: self)
        print("delete button clicked")
    }
    
    @IBAction func acceptButtonClicked(_ sender: Any) {
        addFriendsCellDelegate?.acceptRequest(in: self)
    }
    
    @IBAction func usernameButtonClicked(_ sender: Any) {
        addFriendsCellDelegate?.viewProfile(in: self)
    }
    
}

protocol AddFriendsCellDelegate {
    
    func deleteRequest(in cell: AddFriendsCell)
    func acceptRequest(in cell: AddFriendsCell)
    func viewProfile(in cell: AddFriendsCell)
}
