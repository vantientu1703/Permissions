//
//  AppDelegate.swift
//  NotificationFacade
//
//  Created by Văn Tiến Tú on 10/06/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let vc = storyboard.instantiateViewController(identifier: "ViewController")
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        } else {
            let vc = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        return true
    }
}

