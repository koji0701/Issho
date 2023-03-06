//
//  Photo Selector Header.swift
//  Issho-New
//
//  Created by Koji Wong on 2/28/23.
//

import Foundation

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .darkGray
        //make background color
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = min(iv.frame.width, iv.frame.height) / 2

        return iv
    }()
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        let diameter = min(bounds.width, bounds.height)
        photoImageView.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        photoImageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        print("center", photoImageView.center)
        print("frame", photoImageView.frame)
        
        photoImageView.layer.cornerRadius = diameter / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
        setupBlur()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
        setupBlur()
    }
    
    var animator: UIViewPropertyAnimator!
    
    private func setupBlur() {
        let visualEffectView = UIVisualEffectView()
        visualEffectView.frame = photoImageView.frame
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoImageView.addSubview(visualEffectView)
        //visualEffectView.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor, bottom: photoImageView.bottomAnchor, right: photoImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        visualEffectView.effect = UIBlurEffect(style: .regular)

        
        
        //visualEffectView.alpha = 0
        
//        UIView.animate(withDuration: 1) {
//            visualEffectView.alpha = 1
//        }
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .easeIn, animations: {
            visualEffectView.effect = nil
        })
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = 0.5
        print(animator.fractionComplete)
    }
    
    private func sharedInit() {
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
