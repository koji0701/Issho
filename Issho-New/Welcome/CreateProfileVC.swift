//
//  CreateProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 9/26/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CreateProfileVC: UIViewController {
    
    
    @IBOutlet weak var picButton: UIButton!
    
    @IBOutlet weak var username: FormTextField!
    
    @IBOutlet weak var clearPicButton: UIButton!
    
    var authInfo: [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picButton.imageView?.layer.masksToBounds = false
        picButton.clipsToBounds = true
        picButton.imageView?.clipsToBounds = true
        picButton.layer.masksToBounds = true
        picButton.imageView?.layer.cornerRadius = picButton.frame.height / 2
        picButton.layer.cornerRadius = picButton.frame.height / 2
        
        picButton.setImage(CustomImageView.imageCache["default"], for: .normal)
        
        picButton.setTitle("+", for: .normal)
        
        
    }
    
    @IBAction func clearPicButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.picButton.setImage(CustomImageView.imageCache["default"], for: .normal)
            self.picButton.setTitle("+", for: .normal)
        }
    }
    
    
    @IBAction func picButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.CreateProfileToPhotoSelectorController, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoSelectorVC = segue.destination as? PhotoSelectorController {
            photoSelectorVC.setMosiacLayout()
        }
    }
    
    func setPic(image: UIImage?) {
        print("image: ", image)
        guard let pic = image else {return }
        let resizedImage = pic.resize(to: CGSize(width: picButton.frame.width, height: picButton.frame.height))

        
        DispatchQueue.main.async {
            self.picButton.setImage(resizedImage, for: .normal)
            self.picButton.setTitle("", for: .normal)
        }
        
        print("imageView pic ", picButton.imageView?.image)

    }
    
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        guard let usernameText = username.text else {
            return
        }
        
        //check if theres special symbols or space
        if usernameText.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .symbols).count != usernameText.count {
            return
        }
        
        let maxCharacterCountForUsername = 15
        if usernameText.count > maxCharacterCountForUsername {//too long
            return
        }
        
        //since passes conditions, create account
        
        Auth.auth().createUser(withEmail: authInfo["email"]!, password: authInfo["password"]!) { authResult, error in
            if let e = error {
                print(e.localizedDescription)
            }
            
            else {
                //MARK: continue
                //METHOD TO UPLOAD THE IMAGE?? CHECK GITHUB CROSS CHECK, UID MATCH?
                //can i just do the same thung as in the editprofilevc where i just check it against the CustomImageView saved images?
                
                guard let uid = authResult?.user.uid else {return}
                
                
                if (self.picButton.imageView!.image == CustomImageView.imageCache["default"]) {
                    Firestore.initializeUser(uid: uid, username: usernameText, image: "default")//MARK: NEEDS IMAGE

                }
                else {
                    self.uploadImage(newPic: self.picButton.imageView!.image!, uid: uid, completion: { err in
                        if let e = err {
                            print(e)
                        }
                        Firestore.initializeUser(uid: uid, username: usernameText, image: uid) //after uploading, make the user
                        
                    })
                }
                
                // segue to the home screen
                self.performSegue(withIdentifier: Constants.Segues.createProfileToTabBar, sender: self)
                
            }
        }
        
    }
    
    private func uploadImage(newPic: UIImage, uid: String, completion: @escaping (Error?) -> Void) {
        let data = newPic.jpegData(compressionQuality: 0.8)!
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        
        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                completion(error)
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completion(error)
                    return
                }
            }
            
            if let currentImage = CustomImageView.imageCache[User.shared().uid] {
                CustomImageView.imageCache.removeValue(forKey: User.shared().uid)
            }
            else {
                
                User.shared().userInfo["image"] = User.shared().uid
                Firestore.updateUserInfo(uid: User.shared().uid, fields: ["image": User.shared().uid])
            }
            completion(nil)
        }
        
    }
    
    
    
    
}
