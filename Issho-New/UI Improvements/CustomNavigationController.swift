//
//  CustomNavigationBar.swift
//  Issho-New
//
//  Created by Koji Wong on 2/27/23.
//

import Foundation
import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isTranslucent = true
        
        backIndicatorImage = UIImage(named: "back")
        backIndicatorTransitionMaskImage = UIImage(named: "back")
        titleTextAttributes = [
            NSAttributedString.Key.font: Constants.Fonts.navigationBarTitleFont
        ]
    }
    
}
