//
//  AppDelegate.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 25/06/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController.fromStoryboard(.main)!
        let nav = UINavigationController(rootViewController: vc)
        nav.title = "Permissions"
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }
}
