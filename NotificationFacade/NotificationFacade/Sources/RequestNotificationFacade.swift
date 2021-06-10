//
//  NotificationFacade.swift
//  NotificationFacade
//
//  Created by Văn Tiến Tú on 10/06/2021.
//

import UIKit

class RequestNotificationFacade {
    
    weak var controller: UIViewController?
    
    private lazy var center: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        return center
    }()
    
    init(from viewController: UIViewController?) {
        self.controller = viewController
    }
    
    func requestNotifications(hasRemoteNotification: Bool = false, completion: ((_ granted: Bool) -> ())?) {
        RequestNotificationFacade.notificationStatus { [weak self] (status) in
            guard let self = self else { return }
            switch status {
            case .authorized:
                completion?(true)
            case .denied:
                DispatchQueue.main.async { [weak self] in
                    if self?.controller != nil {
                        self?.alertSettings { (granted) in
                            completion?(granted)
                        }
                    } else {
                        completion?(false)
                    }
                }
            default:
                self.requestPermission(hasRemoteNotification: hasRemoteNotification) { (granted) in
                    completion?(granted)
                }
            }
        }
    }
    
    private func alertSettings(completion: ((_ granted: Bool) -> ())?) {
        let alertController = UIAlertController(title: "Notification Settings", message: "Do you want go to Settings to turn on Notifications?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            completion?(false)
        }
        let okAction = UIAlertAction(title: "Settings", style: .default) { [weak self] (_) in
            self?.gotoSettings()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.controller?.present(alertController, animated: true, completion: nil)
    }
    
    private func gotoSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    
    private func requestPermission(hasRemoteNotification: Bool, completion: ((_ granted: Bool) -> ())?) {
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
        UNUserNotificationCenter.current()
            .getNotificationSettings { (settings) in
                completion?(settings.authorizationStatus)
            }
    }
    
    func notificationStatus(completion: ((_ status: UNAuthorizationStatus) -> ())?) {
        self.center.getNotificationSettings { (settings) in
            completion?(settings.authorizationStatus)
        }
    }
    
    deinit {
        print("deinited RequestNotificationFacade")
    }
}
