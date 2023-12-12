//
//  EditProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 3/2/23.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var picButton: UIButton!
    
    
    @IBAction func clearImageButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.picButton.setImage(UIImage(), for: .normal)
            self.picButton.setTitle("+", for: .normal)
        }
        

    }
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButtons()
        username.text = User.shared().userInfo["username"] as? String
        username.borderStyle = .roundedRect
        picButton.imageView?.layer.masksToBounds = false
        picButton.clipsToBounds = true
        picButton.imageView?.clipsToBounds = true
        picButton.layer.masksToBounds = true
        picButton.imageView?.layer.cornerRadius = picButton.frame.height / 2
        picButton.layer.cornerRadius = picButton.frame.height / 2
        
        if (User.shared().userInfo["image"] as? String == "default") {
            picButton.setImage(nil, for: .normal)
            picButton.setTitle("+", for: .normal)
        }
        else {
            picButton.setTitle("", for: .normal)
            setPic(image: CustomImageView.imageCache[User.shared().userInfo["image"] as! String] )

        }
    }
    
    
    @IBAction func picButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.editProfileToPhotoSelector, sender: nil)
    }
    
    
    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .systemBlue
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleNext))
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
    
    
    @objc
    private func handleNext() {
        
        //upload to the firebase database
        guard let newPic = picButton.imageView?.image else {
            User.shared().userInfo["image"] = "default"

            Firestore.updateUserInfo(uid: User.shared().uid, fields: ["image": "default"])
            CustomImageView.imageCache.removeValue(forKey: User.shared().uid)

            navigationController?.popViewController(animated: true)
            return
        }
        if newPic == UIImage() {
            User.shared().userInfo["image"] = "default"

            Firestore.updateUserInfo(uid: User.shared().uid, fields: ["image": "default"])
            CustomImageView.imageCache.removeValue(forKey: User.shared().uid)

            navigationController?.popViewController(animated: true)
            return
            
        }
        uploadImage(newPic: newPic, completion: { err in
            if let e = err {
                print(e)
            }
            
            self.navigationController?.popViewController(animated: true)
        })

        
    }
    
    
    
    private func uploadImage(newPic: UIImage, completion: @escaping (Error?) -> Void) {
        let data = newPic.jpegData(compressionQuality: 0.8)!
        let storageRef = Storage.storage().reference().child("profilePictures/\(User.shared().uid).jpg")
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoSelectorVC = segue.destination as? PhotoSelectorController {
            photoSelectorVC.setMosiacLayout()
        }
    }
    
    
    
}
