//
//  MiscExtensions.swift
//  Issho-New
//
//  Created by Koji Wong on 2/7/23.
//

import Foundation
import UIKit

extension String {//for backspace
  var isBackspace: Bool {
    let char = self.cString(using: String.Encoding.utf8)!
    return strcmp(char, "\\b") == -92
  }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.23
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        layer.cornerRadius = 8
    }
}

class RoundedShadowView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        layer.masksToBounds = false
        //MARK: continue here. tried to get shadow around the headerview in todo, but couldnt. coi;d it be that the shadow is just off screeN?
    }
    
}
