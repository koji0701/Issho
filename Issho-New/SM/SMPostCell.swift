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

    
    @IBOutlet weak var profilePicture: CustomImageView!
    
    @IBOutlet weak var profilePictureTapView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var customProgressBar: GradientHorizontalProgressBar!
    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var streak: UILabel!

    
    @IBOutlet weak var progressPercentage: UILabel!
    
    
    @IBOutlet weak var likesView: UIView!
    
    @IBOutlet weak var likesButton: UIButton!
    
    private let unlikedLikeImage = (UIImage(named: "party.popper") ?? UIImage(systemName: "suit.heart")!).withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium))
    private let likedLikeImage = (UIImage(named: "party.popper.fill") ?? UIImage(systemName: "suit.heart.fill")!).withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium))
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //profilePicView.clipsToBounds = true
        username.font = Constants.Fonts.smUsernameFont
        progressPercentage.font = Constants.Fonts.progressBarFont
        likes.font = Constants.Fonts.smUsernameFont
        streak.font = Constants.Fonts.smUsernameFont
        
        
        
        likesView.addSeparator(at: .top, color: .lightGray, weight: 1.5, insets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        
        
        likesButton.clipsToBounds = true
        
        likesButton.setImage(unlikedLikeImage, for: .normal)
        likesButton.setImage(likedLikeImage, for: .selected)
        likesButton.tintColor = .gray
        
        

        profilePictureTapView.isUserInteractionEnabled = true
        username.isUserInteractionEnabled = true
        profilePicture.image = profilePicture.image?.resize(to: CGSize(width: profilePicture.frame.width, height: profilePicture.frame.height))
        
        let profileTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        let usernameTapToSegue = UITapGestureRecognizer(target: self, action: #selector(handleSegueAction(_:)))
        
        
        profilePictureTapView.addGestureRecognizer(profileTapToSegue)
        username.addGestureRecognizer(usernameTapToSegue)
        
        
        let doubleTapToLike = UITapGestureRecognizer(target: self, action: #selector(handleLike))
        doubleTapToLike.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapToLike)
        likesButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)


        //shadow cells
        // add shadow on cell
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        
    }

    
    
    @objc private func handleLike() {
        

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
        
        print("like animation performed")
        likesButton.setImage(likedLikeImage, for: .normal)
        likesButton.tintColor = .black
        customProgressBar.pulseAnimation()
        
        likesButton.pulse()
    }
    
    
    
    
}
