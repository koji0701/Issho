//
//  AddFriendsViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 2/7/23.
//

import Foundation
import UIKit

class AddFriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [String]()//set in the to do view controller when initFirestore
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.SM.addFriendsNibName, bundle: nil), forCellReuseIdentifier: Constants.SM.addFriendsReuseIdentifier)

    }
}

extension AddFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SM.addFriendsReuseIdentifier, for: indexPath) as! AddFriendsCell
        
        return cell
    }
    
    
}


