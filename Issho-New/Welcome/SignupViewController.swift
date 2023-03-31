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
    
    @IBOutlet weak var signup: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: put in username textfield
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        
        print("signup button clicked")
        if let email = emailTextField.text, let password = passwordTextField.text, let username = emailTextField.text {
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
        let background = UIImage(named: "background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        /*let customColor = UIColor.white
        emailTextField.layer.borderColor = customColor.cgColor
        passwordTextField.layer.borderColor = customColor.cgColor
        
        emailTextField.layer.borderWidth = 4.0
        passwordTextField.layer.borderWidth = 4.0
        */
        emailTextField.layer.cornerRadius = emailTextField.frame.height / 2
        passwordTextField.layer.cornerRadius = passwordTextField.frame.height / 2
        
        /*
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )*/
        emailTextField.backgroundColor = .white.withAlphaComponent(0.8)
        passwordTextField.backgroundColor = .white.withAlphaComponent(0.8)
        
        emailTextField.font = Constants.Fonts.welcomeForms
        passwordTextField.font = Constants.Fonts.welcomeForms
        
        emailTextField.textColor = .darkGray
        passwordTextField.textColor = .darkGray
        
        signup.titleLabel?.font = Constants.Fonts.welcomeSignupButton
        signup.backgroundColor = .white.withAlphaComponent(0.9)
        
        
        welcomeLabel.font = UIFont(name: "NunitoSans-Black", size: 50)
        
    }
}
