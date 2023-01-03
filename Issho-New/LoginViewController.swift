//
//  LoginViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/2/23.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.loginToTabBar, sender: self)
    }
    
    
}
