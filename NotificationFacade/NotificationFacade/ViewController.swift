//
//  ViewController.swift
//  NotificationFacade
//
//  Created by Văn Tiến Tú on 10/06/2021.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var facade: RequestNotificationFacade = {
        return RequestNotificationFacade(from: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        facade.requestNotifications(hasRemoteNotification: true) { (granted) in
            print("granted notifications")
        }
        
//        print("hasBiometrics ", BiometricIDAuth().hasBiometrics)
//        print("availabelFaceId ", BiometricIDAuth().availabelFaceId)
//        print("availabelTouchId ", BiometricIDAuth().availabelTouchId)
//        BiometricIDAuth().requestPermission { (granted) in
//            print("granted ", granted)
//        }
    }
}

