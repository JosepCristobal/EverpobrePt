//
//  AppDelegate.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 21/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        
        // let noteVC = NoteViewByCodeController()  // NoteViewController()  //
        let notesTVC = NotesTableViewController(style: .plain)
        notesTVC.title = "Everpobre Notes"
        let navController = UINavigationController(rootViewController: notesTVC)
        
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
        
        //let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //print(documentDirectory.absoluteString)
        
        return true
    }
    

    
}


