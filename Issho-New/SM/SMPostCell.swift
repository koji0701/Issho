//
//  SMPostCell.swift
//  Issho
//
//  Created by Koji Wong on 6/20/22.
//

import UIKit

class SMPostCell: UITableViewCell {


    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var progressBar: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var streak: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // profilePicView set to image
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
