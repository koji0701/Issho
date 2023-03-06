//
//  SignupViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/2/23.
//

import Foundation
import UIKit
//import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        
        print("signup button clicked")
        if let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                }
                
                else {
                    guard let uid = authResult?.user.uid else {return}
                    print("signed up")
                    Firestore.initializeUser(uid: uid, username: username, image: "")//MARK: NEEDS IMAGE 
                    self.performSegue(withIdentifier: Constants.Segues.signupToTabBar, sender: self)
                    
                }
            }
        }
        
        
        
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
