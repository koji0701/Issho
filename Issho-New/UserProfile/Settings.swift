//
//  Settings.swift
//  Issho-New
//
//  Created by Koji Wong on 4/3/23.
//

import Foundation
import UIKit

struct Settings {
    
    static var showCompletedEntries = true
    static var displayMode = 1
    
    static let toDoProgressUntilDate = 0
    
    
    struct progressBar {
        static let hasNotFinishedToday = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.5)
        static let bgHasNotFinishedToday = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.1)//very light purple, sort of clear
        
        static let hasFinishedToday = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.8)
        static let bgHasFinishedToday = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.3)
    }
    
    
    
    
}
