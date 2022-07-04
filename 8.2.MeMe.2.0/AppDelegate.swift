//
//  AppDelegate.swift
//  4.1imagePicker
//
//  Created by mairo on 19/03/2022.
//

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow? // new 2.0
    var memes = [Meme]() // new 2.0
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // remove border of the navigationBar
        UINavigationBar.appearance().shadowImage = UIImage()
        
        // remove border of the Toolbar
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

