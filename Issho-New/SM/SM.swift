//
//  SM.swift
//  Issho
//
//  Created by Koji Wong on 11/10/22.
//

import Foundation

struct SM {//OUTDATED
    let username: String
    let active: Bool //true vs false active inactive
    var progress: Int //progress bar
    let streak: Int //let or var?
    
    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String ?? ""
        active = dictionary["active"] as? Bool ?? false
        progress = dictionary["progress"] as? Int ?? 0
        streak = dictionary["streak"] as? Int ?? 0
    }
    
    
    
}
