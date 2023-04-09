//
//  FriendsControlButton.swift
//  Issho-New
//
//  Created by Koji Wong on 4/9/23.
//

import Foundation
import UIKit

class FriendsControlButton: UIButton {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.secondarySystemBackground
        tintColor = UIColor.label
        layer.cornerRadius = 15.0 // Rounded corners
        setTitle("Add", for: .normal)
        setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        semanticContentAttribute = .forceLeftToRight // To align the text to the right of the image
        titleLabel?.font = Constants.Fonts.friendsControlFont

    }
    
    func updateState() {
        
        if (currentTitle == "Add") {
            setState(state: .requested)
        }
        
        
        else if (currentTitle == "Requested") {
            
            setState(state: .add)

        }
        
        else if (currentTitle == "Friends") {
            
            setState(state: .unfriend)
        }
        
        else if (currentTitle == "Unfriend") {
            setState(state: .add)
        }
        
    }
    
    enum State {
        case add
        case requested
        case friends
        case unfriend
        case thatsYou
        case accept
        case addFriends
        
    }
    
    func setState(state: State) {
        backgroundColor = UIColor.secondarySystemBackground
        
        switch state {
        case .add:
            setTitle("Add", for: .normal)
            setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        case .requested:
            setTitle("Requested", for: .normal)
            setImage(UIImage(systemName: "person.fill.checkmark"), for: .normal)
        case .friends:
            setTitle("Friends", for: .normal)
            setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        case .unfriend:
            setTitle("Unfriend", for: .normal)
            setImage(UIImage(systemName: "person.fill.badge.minus"), for: .normal)
        case .thatsYou:
            setTitle("Thats you!", for: .normal)
            imageView?.image = UIImage()
            backgroundColor = UIColor.tertiarySystemBackground
        case .accept:
            setTitle("Accept", for: .normal)
            setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        case .addFriends:
            setTitle("Add Friends", for: .normal)
            setImage(UIImage(systemName: "person.2.fill"), for: .normal)
            
        }
    }
}
