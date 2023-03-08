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
        
        static let emojis = [
            "🎃",
            "🎄",
            "🎆",
            "🎇",
            "🧨",
            "✨",
            "🎈",
            "🎉",
            "🎊",
            "🎋",
            "🎍",
            "🎎",
            "🎏",
            "🎐",
            "🎑",
            "🧧",
            "🎀",
            "🎁",
            "🎗️",

            "🎟️",

            "🎫",
            "🎖️",

            "🏆",
            "🏅",
            "🥇",
            "🥈",
            "🥉",
            "⚽",
            "⚾",
            "🥎",
            "🏀",
            "🏐",
            "🏈",
            "🏉",
            "🎾",
            "🥏",
            "🎳",
            "🏏",
            "🏑",
            "🏒",
            "🥍",
            "🏓",
            "🏸",
            "🥊",
            "🥋",
            "🥅",

            "⛸️",

            "🎣",
            "🤿",
            "🎽",
            "🎿",
            "🛷",
            "🥌",
            "🎯",
            "🪀",
            "🪁",
            "🎱",
            "🔮",
            "🪄",
            "🧿",
            "🎮",
            "🕹️",

            "🎰",
            "🎲",
            "🧩",
            "🧸",
            "🪅",
            "🪆",
            "♠️",

            "♥️",

            "♦️",

            "♣️",

            "♟️",

            "🃏",
            "🀄",
            "🎴",
            "🎭",
            "🖼️",

            "🎨",
            "🧵",
            "🪡",
            "🧶",
            "🪢",
            "🐵",
            "🐒",
            "🦍",
            "🦧",
            "🐶",
            "🐕",
            "🦮",
            "🐕‍🦺",
            "🐩",
            "🐺",
            "🦊",
            "🦝",
            "🐱",
            "🐈",
            "🐈‍⬛",
            "🦁",
            "🐯",
            "🐅",
            "🐆",
            "🐴",
            "🐎",
            "🦄",
            "🦓",
            "🦌",
            "🦬",
            "🐮",
            "🐂",
            "🐃",
            "🐄",
            "🐷",
            "🐖",
            "🐗",
            "🐽",
            "🐏",
            "🐑",
            "🐐",
            "🐪",
            "🐫",
            "🦙",
            "🦒",
            "🐘",
            "🦣",
            "🦏",
            "🦛",
            "🐭",
            "🐁",
            "🐀",
            "🐹",
            "🐰",
            "🐇",
            "🐿️",

            "🦫",
            "🦔",
            "🦇",
            "🐻",
            "🐻‍❄️",
            "🐻‍❄",
            "🐨",
            "🐼",
            "🦥",
            "🦦",
            "🦨",
            "🦘",
            "🦡",
            "🐾",
            "🦃",
            "🐔",
            "🐓",
            "🐣",
            "🐤",
            "🐥",
            "🐦",
            "🐧",
            "🕊️",

            "🦅",
            "🦆",
            "🦢",
            "🦉",
            "🦤",
            "🪶",
            "🦩",
            "🦚",
            "🦜",
            "🐸",
            "🐊",
            "🐢",
            "🦎",
            "🐍",
            "🐲",
            "🐉",
            "🦕",
            "🦖",
            "🐳",
            "🐋",
            "🐬",
            "🦭",
            "🐟",
            "🐠",
            "🐡",
            "🦈",
            "🐙",
            "🐚",
            "🐌",
            "🦋",
            "🐛",
            "🐜",
            "🐝",
            "🪲",
            "🐞",
            "🦗",
            "🪳",
            "🕷️",

            "🕸️",

            "🦂",
            "🦟",
            "🪰",
            "🪱",
            "🦠",
            "💐",
            "🌸",
            "💮",
            "🏵️",

            "🌹",
            "🥀",
            "🌺",
            "🌻",
            "🌼",
            "🌷",
            "🌱",
            "🪴",
            "🌲",
            "🌳",
            "🌴",
            "🌵",
            "🌾",
            "🌿",
            "☘️",

            "🍀",
            "🍁",
            "🍂",
            "🍃"
        ]
    }
    
    struct SM {
        static let nibName = "SMPostCell"
        static let reuseIdentifier = "SMReusablePostCell"
        
        static let addFriendsNibName = "AddFriendsCell"
        static let addFriendsReuseIdentifier = "AddFriendsReusableCell"
    }
    
    struct Segues {
        static let signupToLogin = "SignupToLogin"
        static let loginToTabBar = "LoginToTabBar"
        static let signupToTabBar = "SignupToTabBar"
        
        static let addFriendsToUserProfile = "AddFriendsToUserProfile"
        static let SMToUserProfile = "SMToUserProfile"
        
        static let profileToSettings = "profileToSettings"
        static let profileToAddFriends = "profileToAddFriends"
        
        static let settingsToEditProfile = "settingsToEditProfile"
        static let editProfileToPhotoSelector = "editProfileToPhotoSelector"
    }
    
    struct FBase {
        static let collectionName = "users"
        
    }
    struct Settings {
        
        static var showCompletedEntries = true
        static var displayMode = 1
    }
    
    struct Fonts {
        static let toDoEntryCellFont = UIFont(name: "NunitoSans-Regular", size: 16)
        static let toDoEntrySectionHeaderFont = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        static let navigationBarTitleFont = UIFont(name: "NunitoSans-ExtraBold", size: 23)
        
        
        
    }
    
    struct Images {
        static let unlikedLikeImage = UIImage(named: "party.popper") ?? UIImage(systemName: "suit.heart")!
    }
}
