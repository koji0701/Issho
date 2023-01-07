//
//  SMViewController.swift
//  Issho
//
//  Created by Koji Wong on 6/20/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SMViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var posts = [Post]()
    
    
    private func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        db.collection(Constants.FBase.collectionName).whereField("friends", arrayContains: uid).addSnapshotListener { querySnapshot, error in
            self.posts = []
            print("found the friend")
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    print("snapshot documents = querysnapshot? documents")
                    for doc in snapshotDocuments {
                        print("found one doc")
                        let data = doc.data()
                        
                        
                        if let likesCount = data["likesCount"] as? Int, let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Int, let likes = data["likes"] as? [String]{
                            print("got past the if let conditions")
                            let isLiked = likes.contains(uid)//if likes contains uid, true its been liked
                            let dict: [String: Any] = ["likesCount": likesCount, "streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "isLiked": isLiked]
                            
                            
                            let newPost = Post(uid: doc.documentID, dictionary: dict)
                            self.posts.append(newPost)
                            print(self.posts.count)
                            DispatchQueue.main.async {
                                self.orderPosts()
                                self.tableView.reloadData()
                                print("posts are currently \(self.posts)")
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func orderPosts() {
        posts.sort {
            if ($0.isLiked != $1.isLiked) {
                return $0.isLiked
            }
            else {
                return $0.lastUpdated > $1.lastUpdated
            }
            
        }
    }
    
    
    
    private func updateLikeInFirestore(post: Post) {
        
       
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let postUID = post.uid
            Firestore.updateUserInfo(uid: postUID, field: "likesCount", value: FieldValue.increment(1.0))
            db.collection(Constants.FBase.collectionName).document(postUID).updateData([
                "likes": FieldValue.arrayUnion([uid])
            ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchPosts()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.nibName, bundle: nil), forCellReuseIdentifier: Constants.SM.reuseIdentifier)
        
    }
}

extension SMViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.reuseIdentifier, for: indexPath) as! SMPostCell
        
        return cell
    }
    
    
}
