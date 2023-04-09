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
        layer.cornerRadius = 10.0 // Rounded corners
        setTitle("Add", for: .normal)
        setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        semanticContentAttribute = .forceRightToLeft // To align the text to the right of the image
    }
    
    func setState(state: String) {
        if (state == "Add") {
            setTitle("Add", for: .normal)
            setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        }
        
    }
}
