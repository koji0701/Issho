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
    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var streak: UILabel!

    
    @IBOutlet weak var progressPercentage: UILabel!
    
    
    @IBOutlet weak var likesView: UIView!
    
    @IBOutlet weak var likesButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //profilePicView.clipsToBounds = true
        
        likesView.addSeparator(at: .top, color: .lightGray, weight: 1.5, insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        
        likesButton.clipsToBounds = true

        /*let pic = UIImage(systemNam: "party.popper")!.withConfiguration(symbolConfig)
        likesButton.setImage(pic, for: .normal)*/
        
        if let pic = UIImage(systemName: "party.popper")?.withConfiguration(symbolConfig)  {
            likesButton.setImage(pic, for: .normal)
        }
        else {
            print("could not find pic")
        }

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
        layer.shadowRadius = 19
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
