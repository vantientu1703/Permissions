//
//  NotificationFacade.swift
//  NotificationFacade
//
//  Created by Văn Tiến Tú on 10/06/2021.
//

import UIKit

@available(iOS 10, *)
class NotificationPermission {
    private static var center: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        return center
    }()
    
    static func requestNotificationPermission(from viewController: UIViewController?,
                                              hasAlertIfPermissionDenied: Bool = false,
                                              hasRemoteNotification: Bool = false, completion: ((_ granted: Bool) -> ())?) {
        self.notificationStatus { (status) in
            switch status {
            case .authorized:
                completion?(true)
            case .denied:
                    if hasAlertIfPermissionDenied {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11, execute: {
                            self.presentAlertSettings(from: viewController, completion: completion)
                        })
                    } else {
                        completion?(false)
                    }
            default:
                self.requestPermission(hasRemoteNotification: hasRemoteNotification) { (granted) in
                    completion?(granted)
                }
            }
        }
    }
    
    private static func presentAlertSettings(from viewController: UIViewController?, completion: ((_ granted: Bool) -> ())?) {
        let alertController = UIAlertController(title: "Notification Settings",
                                                message: "Do you want go to Settings to turn on Notifications?",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            completion?(false)
        }
        let okAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            self.gotoSettings()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11, execute: {
            viewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
    private static func gotoSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    
    private static func requestPermission(hasRemoteNotification: Bool, completion: ((_ granted: Bool) -> ())?) {
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                if hasRemoteNotification {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion?(granted)
            }
        }
    }
    
    static func notificationStatus(completion: ((_ status: UNAuthorizationStatus) -> ())?) {
        self.center.getNotificationSettings { (settings) in
            completion?(settings.authorizationStatus)
        }
    }
}
