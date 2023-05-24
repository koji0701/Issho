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
            setImage(UIImage(), for: .normal)
            backgroundColor = UIColor.tertiarySystemBackground
        case .accept:
            setTitle("Accept", for: .normal)
            setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        case .addFriends:
            
            makeAddFriends {
                //MARK: CONTINUE HERE I THINK? THIS COMMENT WAS WRITTEN RANDOMLY WHEN I CAME BACK TO LOOK AT THIS CODE AND IDK WAHTS GOING ON HERE
            }
            
            
            
        }
    }
    
    private func makeAddFriends(completion: @escaping () -> Void) {
        setTitle("Add Friends", for: .normal)
        setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        
        completion()
    }
    
    private var badgeLayer: CAShapeLayer?

    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = Settings.progressBar.hasFinishedToday, andFilled filled: Bool = true) {

        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        layer.addSublayer(badge)

        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)

        // Save Badge as UIBarButtonItem property
        badgeLayer = badge
    }

    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }

    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
