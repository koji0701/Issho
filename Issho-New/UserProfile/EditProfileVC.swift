//
//  EditProfileVC.swift
//  Issho-New
//
//  Created by Koji Wong on 3/2/23.
//

import Foundation
import UIKit
import FirebaseStorage

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var picButton: UIButton!
    
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
            navigationController?.popViewController(animated: true)
            return
        }
        
        let data = newPic.jpegData(compressionQuality: 0.8)!
        let storageRef = Storage.storage().reference().child("profilePictures/\(User.shared().uid).jpg")
        
        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
        navigationController?.popViewController(animated: true)

        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoSelectorVC = segue.destination as? PhotoSelectorController {
            photoSelectorVC.setMosiacLayout()
        }
    }
    
    
    
}
