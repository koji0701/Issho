//
//  FirebaseUtilities.swift
//  Issho-New
//
//  Created by Koji Wong on 1/6/23.
//

import Foundation
import FirebaseFirestore

fileprivate let db = Firestore.firestore()

extension Firestore {
    
    static func updateUserInfo(uid: String, field: String, value: Any) {
        db.collection(Constants.FBase.collectionName).document(uid).updateData([
            field: value
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    static func updateUserInfo(uid: String, fields: [String: Any]) {
        db.collection(Constants.FBase.collectionName).document(uid).updateData(fields) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    
    /**static func readUserDocument(uid: String) -> [String: Any] {
        let docRef = db.collection(Constants.FBase.collectionName).document(uid)
        var rV: [String: Any] = ["": ""]
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("was able to read document data")
                rV = document.data()!
                
            } else {
                print("Document does not exist")
                fatalError("could not read user document, readUserDocument")
            }
        }
        return rV
    }**/
    
    
    static func initializeUser(uid: String, username: String) {
        
        
        db.collection(Constants.FBase.collectionName).document(uid).setData([
            "username": username,
            "likesCount": 0,
            "streak": 0,
            "progress": 0,
            "isWorking": false,
            "lastUpdated": 0,
            "friends": [String](),
            "likes": [String](),
            
        ])

    }
    
}
