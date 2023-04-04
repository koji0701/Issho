//
//  SettingsViewController.swift
//  Issho-New
//
//  Created by Koji Wong on 1/11/23.
//

import Foundation
import UIKit

protocol SettingsToDoViewControllerDelegate {
    func refreshTableView()
}

class SettingsViewController: UIViewController {
    let defaults = UserDefaults.standard

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var completedTasksButton: UIButton!
    
    @IBOutlet weak var displayModeButton: UIButton!
    
    
    
    @IBAction func editProfileButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.settingsToEditProfile, sender: nil)
    }
    
    var settingsToDoViewControllerDelegate: SettingsToDoViewControllerDelegate!
    
    override func viewDidLoad() {
        
        setCompletedTasksButtonDisplay(mode: Constants.Settings.showCompletedEntries)
        
        /* TODO:
            
         - CREATE ANIMATION FUNC W/ EXTENSIONS TO UIBUTTON AND APPLY. TAKE IN PARAMTERS FOR MODE/COLORSPACES 
         
         */
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""
    }
    
    
    @IBAction func completedTasksButtonClicked(_ sender: Any) {
        //toggle mode in userdefaults and constants
        defaults.set(!Constants.Settings.showCompletedEntries, forKey: "showCompletedEntries")
        Constants.Settings.showCompletedEntries = !Constants.Settings.showCompletedEntries
        
        setCompletedTasksButtonDisplay(mode: Constants.Settings.showCompletedEntries)
        //reload tableview
        //settingsToDoViewControllerDelegate?.refreshTableView()
        
        
        if let toDoVC = tabBarController?.viewControllers![0].children[0] as? ToDoViewController {
            toDoVC.refreshTableViewMode()
            print("completed tasks button clicked working")
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
        
        
    }
    
    private func setCompletedTasksButtonDisplay(mode: Bool) {
        if (mode == true) {//show completed entries
            //set to yes state, fix later
            completedTasksButton.setTitle("Yes", for: .normal)
            
        }
        else {
            completedTasksButton.setTitle("No", for: .normal)
        }
    }
    
    
    
    
}
