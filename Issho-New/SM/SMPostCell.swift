//
//  SMPostCell.swift
//  Issho
//
//  Created by Koji Wong on 6/20/22.
//

import UIKit

protocol PostDelegate {
    func likedPost(in cell: SMPostCell) -> Bool
    func segueToUserProfile(in cell: SMPostCell)
}

class SMPostCell: UITableViewCell {

    var postDelegate: PostDelegate!

    
    
    @IBOutlet weak var profilePictureTapView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var streak: UILabel!

    
    @IBOutlet weak var progressPercentage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // profilePicView set to image
        
        //profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        //profilePicView.clipsToBounds = true
        profilePictureTapView.isUserInteractionEnabled = true
        username.isUserInteractionEnabled = true
        
        let profileTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        let usernameTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        
        
        profilePictureTapView.addGestureRecognizer(profileTapToSegue)
        username.addGestureRecognizer(usernameTapToSegue)
        
        
        let doubleTapToLike = UITapGestureRecognizer(target: self, action: #selector(handleLike(_:)))
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

    
    
    @objc private func handleLike(_ gestureRecognizer: UITapGestureRecognizer) {
        print("double tapped")
        

        let postLiked = postDelegate?.likedPost(in: self)
        
        if postLiked == true {//able to like the post
            print("will perform like animation")
            performLikeAnimation()
        }
    }
    @objc private func handleSegueAction(_ gestureRecognizer: UITapGestureRecognizer)
    {
        print("clicked")
        postDelegate?.segueToUserProfile(in: self)
    }
    
    
    private func performLikeAnimation() {
        //MARK: LIKE ANIMATION NOT DONE
        //MARK: CONTINUE HERE. ANIMATION STUFF HERE, COPY DOWN THE LIKES ANIMATION FROM THE INSTAGRAM CLONE.
        print("like animation performed")
        
        //contentView.backgroundColor = .yellow//testing color
        
    }
    
    
    
    
}
/*
extension SMPostCell {
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
}
*/
