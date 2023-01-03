//
//  SignupViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/2/23.
//

import Foundation
import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.signupToTabBar, sender: self)
    }
    
    @IBAction func loginSwitchButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.signupToLogin, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.borderStyle = .bezel
        emailTextField.text = "Email"
    }
}
