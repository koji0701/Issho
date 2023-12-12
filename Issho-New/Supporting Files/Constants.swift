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
            "🎱",
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
        static let signupToCreateProfile = "SignupToCreateProfile"
        static let CreateProfileToPhotoSelectorController = "createProfileToPhotoSelectorController"
        static let createProfileToTabBar = "CreateProfileToTabBar"
        
        
        static let addFriendsToUserProfile = "AddFriendsToUserProfile"
        static let SMToUserProfile = "SMToUserProfile"
        
        static let profileToSettings = "profileToSettings"
        static let profileToAddFriends = "profileToAddFriends"
        
        static let settingsToEditProfile = "settingsToEditProfile"
        static let editProfileToPhotoSelector = "editProfileToPhotoSelector"
        
        static let toDoToProfileList = "ToDoToProfileList"
        static let userProfileToProfileList = "UserProfileToProfileList"
        static let profileListToUserProfile = "ProfileListToUserProfile"
    }
    
    struct FBase {
        static let collectionName = "users"
        
    }
    
    
    struct Fonts {
        static let toDoEntryCellFont = UIFont(name: "NunitoSans-Regular", size: 16)
        static let toDoEntrySectionHeaderFont = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        static let navigationBarTitleFont = UIFont(name: "NunitoSans-ExtraBold", size: 23)
        
        
        static let progressBarFont = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        
        static let smUsernameFont = UIFont(name: "NunitoSans-ExtraBold", size: 18)
        static let profileListUsernameFont = UIFont(name: "NunitoSans-ExtraBold", size: 18)
        
        static let friendRequestsLabelFont = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        
        static let userProfileUsernameFont = UIFont(name: "NunitoSans-ExtraBold", size: 24)
        static let userProfileAttributesFonts = UIFont(name: "NunitoSans-SemiBold", size: 18)
        
        static let welcomeForms = UIFont(name: "NunitoSans-SemiBold", size: 18)
        static let welcomeSignupButton = UIFont(name: "NunitoSans-ExtraBold", size: 20)
        
        static let friendsControlFont = UIFont(name: "NunitoSans-Regular", size: 15)
    }
    
}
