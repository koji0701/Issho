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
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var signupButton: UIButton!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        
        print("signup button clicked")
        /*
        if let email = emailTextField.text, let password = passwordTextField.text, let username = emailTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                }
                
                else {
                    guard let uid = authResult?.user.uid else {return}
                    Firestore.initializeUser(uid: uid, username: username, image: "")//MARK: NEEDS IMAGE
                    
                    self.performSegue(withIdentifier: Constants.Segues.signupToCreateProfile, sender: self)
                    
                }
            }
        }*/
          
        
        //check if valid email + password
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            let sendInfo = ["email": email, "password": password]
            self.performSegue(withIdentifier: Constants.Segues.signupToCreateProfile, sender: sendInfo)
            
        }
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createProfileVC = segue.destination as? CreateProfileVC {
            createProfileVC.authInfo = sender as? [String: String]
            
        }
    }
    
    
    @IBAction func loginSwitchButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.signupToLogin, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customColor = UIColor.white
        emailTextField.layer.borderColor = customColor.cgColor
        passwordTextField.layer.borderColor = customColor.cgColor
        
        //emailTextField.font = Constants.Fonts.welcomeForms
        //passwordTextField.font = Constants.Fonts.welcomeForms
        
        emailTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderWidth = 1.0
        
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        
        
    }
}
