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
    
    //MARK: accept the userInfoUpdated call in order to update the users shown here. can just compare old update to new update, no need for firestore
    
    
    let db = Firestore.firestore()
    
    var posts = [UserInfo]()
    
    
    func fetchPosts() {
        
        let userDownloader = UserDownloader()
        guard let friends = User.shared().userInfo["friends"] as? [String] else {return}
        
        userDownloader.downloadUsers(uidsToSearch: friends, completion: { userArray, error in
            
            if let error = error {
                print("error in fetchPosts SMVC", error)
                return
            }
            DispatchQueue.main.async {
                self.posts = userArray
                self.orderPosts()
                self.tableView.refreshControl?.endRefreshing()
                print("end refreshing")
                self.tableView.reloadData()
            }
            
            
        })
        
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
        
       
        let uid = User.shared().uid
        let postUID = post.uid
        
        let newTodaysLikes: [String] = {
            var current = [String]()
            current.append(contentsOf: post.todaysLikes)
            current.append(User.shared().uid)
            return current
        }()
        UserDownloader.cachedUsers[postUID]?.likes.append(uid)
        UserDownloader.cachedUsers[postUID]?.todaysLikes = newTodaysLikes
        Firestore.updateUserInfo(uid: postUID, fields: ["likes": FieldValue.arrayUnion([uid]), "todaysLikes": newTodaysLikes])
        
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @objc private func userUpdate(_ notification: Notification) {
        fetchPosts()
        print("recieved user update")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //fetchPosts()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.nibName, bundle: nil), forCellReuseIdentifier: "SMReusablePostCell")
        tableView.delegate = self
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)
        
    }
    @objc private func refresh() {
        User.shared().initUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        fetchPosts()
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
        DispatchQueue.main.async {
            if (self.posts[indexPath.row].isWorking == true) {
                cell.username.text = "⚡️" + self.posts[indexPath.row].username
                
                cell.customProgressBar.createRepeatingAnimation()
                cell.likes.textColor = .darkGray
                cell.streak.textColor = .darkGray
                cell.username.textColor = .black
            }
            else {
                cell.username.text = self.posts[indexPath.row].username
                cell.customProgressBar.resetAnimation()

            }
        }
        
        
        
        
        cell.likesView.isHidden = posts[indexPath.row].isLiked

        if (posts[indexPath.row].isLiked == true) {
            cell.likes.textColor = .gray
            cell.streak.textColor = .gray
            cell.username.textColor = .gray
        }
        else {
            cell.likes.textColor = .darkGray
            cell.streak.textColor = .darkGray
            cell.username.textColor = .black
        }
        
        print(posts[indexPath.row])
        print(posts[indexPath.row].isLiked)
        
        cell.profilePicture.loadImage(urlString: posts[indexPath.row].image)
        cell.streak.text = String(posts[indexPath.row].streak) + "🔥"
        cell.likes.text = String(posts[indexPath.row].todaysLikes.count) + "🎉"
        cell.customProgressBar.progress = CGFloat(posts[indexPath.row].progress)

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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (posts.count == 0) {
            //MARK: add friends button here? put in the footer for view
            return "No friends"
        }
        return nil
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
            posts[indexPath.row].isLiked = true
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
