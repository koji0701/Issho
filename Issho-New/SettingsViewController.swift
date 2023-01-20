//
//  SettingsViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/11/23.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    let defaults = UserDefaults.standard

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var completedTasksButton: UIButton!
    
    @IBOutlet weak var displayModeButton: UIButton!

    
    override func viewDidLoad() {
        
        
        //MARK: CONTINUE
        /**
        QUICK FIX:
            
         - CREATE ANIMATION FUNC W/ EXTENSIONS TO UIBUTTON AND APPLY. TAKE IN PARAMTERS FOR MODE/COLORSPACES 
         
         */
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    
    @IBAction func completedTasksButtonClicked(_ sender: Any) {
        //toggle mode in userdefaults and constants
        defaults.set(!Constants.Settings.showCompletedEntries, forKey: "showCompletedEntries")
        Constants.Settings.showCompletedEntries = !Constants.Settings.showCompletedEntries
        
        //temp testing
        if Constants.Settings.showCompletedEntries == true {
            print("MODE: SHOW set mode completed tasks button to show completed tasks")
        }
        else {
            print("MODE: HIDE set mode completed tasks button to hide completed tasks")
        }
    }
    
    @IBAction func displayModeButtonClicked(_ sender: Any) {
        //toggle mode in constants + userdefaults
        if (Constants.Settings.displayMode > 3) {
            defaults.set(1, forKey: "displayMode")
            Constants.Settings.displayMode = 1
        }
        else {
            defaults.set(Constants.Settings.displayMode + 1, forKey: "displayMode")
            Constants.Settings.displayMode = Constants.Settings.displayMode + 1
        }
        
        //temp testing
        if (Constants.Settings.displayMode == 1) {
            print("display mode automatic")
        }
        else if (Constants.Settings.displayMode == 2) {
            print("display mode light mode")
        }
        else {
            print("display mode dark mode")
        }
    }
    
    
    
    
}
