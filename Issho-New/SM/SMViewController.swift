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
    
    var posts = [UserInfo]()
    
    
    private func fetchPosts() {
        
        db.collection(Constants.FBase.collectionName).whereField("friends", arrayContains: User.shared().uid).addSnapshotListener() { querySnapshot, error in
            self.posts = []
            print("found the friend")
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        
                        if let streak = data["streak"] as? Int, let isWorking = data["isWorking"] as? Bool, let lastUpdated = data["lastUpdated"] as? Timestamp, let username = data["username"] as? String, let progress = data["progress"] as? Float, let likes = data["likes"] as? [String], let friends = data["friends"] as? [String], let friendReq = data["friendRequests"], let image = data["image"] {
                            print("got past the if let conditions")
                            let isLiked = likes.contains(User.shared().uid)//if likes contains uid, true its been liked
                            let dict: [String: Any] = ["streak": streak, "isWorking": isWorking, "lastUpdated": lastUpdated.dateValue(), "username": username, "progress": progress, "isLiked": isLiked, "friends": friends, "friendRequests": friendReq, "image": image, "likes": likes]
                            
                            
                            let newPost = UserInfo(uid: doc.documentID, dictionary: dict)
                            self.posts.append(newPost)
                            DispatchQueue.main.async {
                                self.orderPosts()
                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func orderPosts() {
        posts.sort {
            var mutableFirst = $0
            var mutableSecond = $1
        
            if (mutableFirst.isLiked != mutableSecond.isLiked) {
                return mutableSecond.isLiked
            }
            else {
                return mutableFirst.lastUpdated > mutableSecond.lastUpdated
            }
            
            
            
        }
        
    }
    
    
    
    private func updateLikeInFirestore(post: UserInfo) {
        
       
        guard let uid = Auth.auth().currentUser?.uid else {
            print("could not find current user in updatelikeinfirestore")
            return
        }
        let postUID = post.uid
        
        Firestore.updateUserInfo(uid: postUID, fields: ["likes": FieldValue.arrayUnion([uid])])
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchPosts()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.nibName, bundle: nil), forCellReuseIdentifier: "SMReusablePostCell")
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userProfileVC = segue.destination as? UserProfileVC {
            userProfileVC.user = sender as? UserInfo
            print("userprofilevc user: ", userProfileVC.user)
            //navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    
}

extension SMViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.reuseIdentifier, for: indexPath) as! SMPostCell
        
        cell.postDelegate = self
        if (posts[indexPath.row].isWorking == true) {
            cell.username.text = "⚡️" + posts[indexPath.row].username
        }
        else {
            cell.username.text = posts[indexPath.row].username
        }
        
        
        cell.likesView.isHidden = posts[indexPath.row].isLiked
        print(posts[indexPath.row])
        print(posts[indexPath.row].isLiked)
        
        cell.profilePicture.loadImage(urlString: posts[indexPath.row].image)
        cell.streak.text = String(posts[indexPath.row].streak) + "🔥"
        cell.likes.text = String(posts[indexPath.row].likesCount) + "👏"
        cell.progressBar.progress = posts[indexPath.row].progress
        cell.progressPercentage.text = String(format: "%.0f", posts[indexPath.row].progress * 100) + "%"
        //cell.contentView.backgroundColor = (posts[indexPath.row].isLiked == true) ? .systemYellow : .systemGray6
        
        return cell
    }
    
    //shadow
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }

}

extension SMViewController: PostDelegate {
    func likedPost(in cell: SMPostCell) -> Bool{
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("could not find cell in postdelegate likedpost")
            return false
            
        }
        var post = posts[indexPath.row]
        if (post.isLiked == false) {
            updateLikeInFirestore(post: post)
            return true
        }
        else {
            return false
        }
    }
    func segueToUserProfile(in cell: SMPostCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("could not find cell in postdelegate likedpost")
            return
        }
        
        let info = posts[indexPath.row]
        performSegue(withIdentifier: Constants.Segues.SMToUserProfile, sender: info)
    }
}
