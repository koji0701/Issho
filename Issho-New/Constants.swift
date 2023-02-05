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
    
    struct FBase {
        static let collectionName = "users"
        
    }
    struct Settings {
        
        static var showCompletedEntries = true
        static var displayMode = 1
    }
    
    struct Fonts {
        static let toDoEntryCellFont = UIFont(name: "NunitoSans-Regular", size: 13)
        static let toDoEntrySectionHeaderFont = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        
    }
    
    
}
