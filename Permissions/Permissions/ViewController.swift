//
//  ViewController.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 25/06/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationPermission
            .requestNotificationPermission(from: self,
                                           hasAlertIfPermissionDenied: true,
                                           hasRemoteNotification: true) { granted in
            print(granted)
        }
    }
}

