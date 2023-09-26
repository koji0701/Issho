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
    
    
    @IBOutlet weak var emailTextField: FormTextField!
    
    
    
    @IBOutlet weak var passwordTextField: FormTextField!
    
    
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login")
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient background 
        /*
        let background = UIImage(named: "background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)*/
    }
        
}
    
    

