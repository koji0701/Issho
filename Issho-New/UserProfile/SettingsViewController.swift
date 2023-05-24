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
    
    @IBOutlet weak var profilePic: CustomImageView!
    
    @IBOutlet weak var editProfile: UIButton!
    
    @IBAction func editProfileButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.settingsToEditProfile, sender: nil)
    }
    
    var settingsToDoViewControllerDelegate: SettingsToDoViewControllerDelegate!
    
    override func viewDidLoad() {
        
        setCompletedTasksButtonDisplay(mode: Settings.showCompletedEntries)
        setDisplayMode(mode: Settings.displayMode)
        
        profilePic.loadImage(urlString: User.shared().uid)
        completedTasksButton.backgroundColor = UIColor.secondarySystemBackground
        completedTasksButton.tintColor = UIColor.label
        completedTasksButton.layer.cornerRadius = 15.0 // Rounded corners
        completedTasksButton.titleLabel?.font = Constants.Fonts.friendsControlFont
        
        displayModeButton.backgroundColor = UIColor.secondarySystemBackground
        displayModeButton.tintColor = UIColor.label
        displayModeButton.layer.cornerRadius = 15.0 // Rounded corners
        displayModeButton.titleLabel?.font = Constants.Fonts.friendsControlFont
        
        editProfile.layer.cornerRadius = 15
        editProfile.titleLabel?.font = Constants.Fonts.friendsControlFont
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""
        
        if let customTB = tabBarController as? CustomTabBarController {
            customTB.toggle(hide: true)
        }
        DispatchQueue.main.async {
            self.profilePic.loadImage(urlString: User.shared().userInfo["image"] as? String ?? "default")

        }
        

    }
    
    
    @IBAction func completedTasksButtonClicked(_ sender: Any) {
        //toggle mode in userdefaults and constants
        defaults.set(!Settings.showCompletedEntries, forKey: "showCompletedEntries")
        Settings.showCompletedEntries = !Settings.showCompletedEntries
        
        setCompletedTasksButtonDisplay(mode: Settings.showCompletedEntries)
        //reload tableview
        //settingsToDoViewControllerDelegate?.refreshTableView()
        
        
        if let toDoVC = tabBarController?.viewControllers![0].children[0] as? ToDoViewController {
            toDoVC.refreshTableViewMode()
            print("completed tasks button clicked working")
        }
        
    }
    
    @IBAction func displayModeButtonClicked(_ sender: Any) {
        //toggle mode in constants + userdefaults
        if (Settings.displayMode >= 3) {
            defaults.set(1, forKey: "displayMode")
            Settings.displayMode = 1
        }
        else {
            defaults.set(Settings.displayMode + 1, forKey: "displayMode")
            Settings.displayMode = Settings.displayMode + 1
        }
        setDisplayMode(mode: Settings.displayMode)
        
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
    
    private func setDisplayMode(mode: Int) {
        if (mode == 1) {
            displayModeButton.setTitle("🌗Automatic", for: .normal)
            
            
            tabBarController?.overrideUserInterfaceStyle = .unspecified
            
        }
        if (mode == 2) {
            displayModeButton.setTitle("☀️Light", for: .normal)
            tabBarController?.overrideUserInterfaceStyle = .light
            
        }
        if (mode == 3) {
            displayModeButton.setTitle("🌑Dark", for: .normal)
            tabBarController?.overrideUserInterfaceStyle = .dark
        }
    }
    
    
    
}
