//
//  LoginViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/2/23.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    strongSelf.performSegue(withIdentifier: Constants.Segues.loginToTabBar, sender: strongSelf)
                    
                    
                }
            }
            
            
            
        }
    }
        
}
    
    

