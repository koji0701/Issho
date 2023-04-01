//
//  CustomImageView.swift
//  Issho-New
//
//  Created by Koji Wong on 3/1/23.
//

import Foundation
import UIKit
import FirebaseStorage

// image caching

var i = 0
var j = 0
let storage = Storage.storage()

class CustomImageView: UIImageView {
    static var imageCache: [String: UIImage] = ["default": UIImage(systemName: "person.circle")!]
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        self.image = nil
        //print("Loading image...")
        lastURLUsedToLoadImage = urlString
        
        if let cachedImage = CustomImageView.imageCache[urlString] {
            //i += 1
           // print("Cache Hit: \(i)")
            self.image = cachedImage
            return
        }
        j += 1
        print("Cache Miss: \(j)")
        
        let imageRef = storage.reference(withPath: "profilePictures/\(urlString).jpg")
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
        
              print(error)
          } else {
              print("was able to pull the image")
              guard let imageData = data else { print("was not able to get image data for the profile pic error")
return}
              let image = UIImage(data: imageData)
              CustomImageView.imageCache[urlString] = image
              DispatchQueue.main.async {
                  self.image = image
              }
              
          }
        }
        
        /*
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            // because of reusing cell
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()*/
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = layer.bounds.height / 2
        layer.masksToBounds = true
    }

}

