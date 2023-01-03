//
//  Constants.swift
//  Issho
//
//  Created by Koji Wong on 10/16/22.
//

import Foundation
import UIKit

struct Constants {
    
    struct ToDo {
        static let nibName = "ToDoEntryCell"
        static let reuseIdentifier = "ToDoReusableEntryCell"
        
    }
    
    struct SM {
        static let nibName = "SMPostCell"
        static let reuseIdentifier = "SMReusablePostCell"
    }
    
    struct Segues {
        static let signupToLogin = "SignupToLogin"
        static let loginToTabBar = "LoginToTabBar"
        static let signupToTabBar = "SignupToTabBar"
    }
    
    
}
