//
//  SMPostCell.swift
//  Issho
//
//  Created by Koji Wong on 6/20/22.
//

import UIKit

protocol PostDelegate {
    func likedPost(in cell: SMPostCell) -> Bool
}

class SMPostCell: UITableViewCell {

    var postDelegate: PostDelegate!

    @IBOutlet weak var profilePicView: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var streak: UILabel!
    
    
    @IBOutlet weak var progressPercentage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // profilePicView set to image
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        profilePicView.clipsToBounds = true
        let doubleTapToLike = UITapGestureRecognizer(target: self, action: #selector(handleLike))
        doubleTapToLike.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapToLike)
        
        
        //shadow cells
        // add shadow on cell
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 19
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        
    }

    
    
    @objc func handleLike() {
        let postLiked = postDelegate?.likedPost(in: self)
        
        if postLiked == true {//able to like the post
            print("will perform like animation")
            performLikeAnimation()
        }
    }
    
    
    private func performLikeAnimation() {
        //MARK: LIKE ANIMATION NOT DONE
        //MARK: CONTINUE HERE. ANIMATION STUFF HERE, COPY DOWN THE LIKES ANIMATION FROM THE INSTAGRAM CLONE.
        print("like animation performed")
        
        //contentView.backgroundColor = .yellow//testing color
        
    }
    
}
