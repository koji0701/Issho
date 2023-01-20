//
//  AppDelegate.swift
//  Issho-New
//
//  Created by Koji Wong on 11/23/22.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

//MARK: I deleted a lot of the default methods that are new bc of the udemy tutorial (different types of interruptions phone calls etc.) if that is a problem paste them in later

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let defaults = UserDefaults.standard
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        print(db)
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        //settings constants init from userdefaults
        Constants.Settings.displayMode = defaults.value(forKey: "displayMode") as? Int ?? 1
        Constants.Settings.showCompletedEntries = defaults.value(forKey: "showCompletedEntries") as? Bool ?? true
        if (defaults.value(forKey: "showCompletedEntries") == nil) {//settings init condition, only check one
            defaults.set(Constants.Settings.displayMode, forKey: "displayMode")
            defaults.set(Constants.Settings.showCompletedEntries, forKey: "showCompletedEntries")
        }
        
        
        return true
    }
    
    


    func applicationWillTerminate(_ application: UIApplication) {

        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "ToDoEntryData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    

    

    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }



}

