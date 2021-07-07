//
//  BiometricViewController.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 02/07/2021.
//

import UIKit

class BiometricViewController: UIViewController {

    @IBOutlet weak var biometricButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if BiometricAuthenticator.canEvaluatePolicyBiometric() {
            switch BiometricAuthenticator.biometryType {
            case .faceID:
                self.biometricButton.setTitle("Face ID", for: .normal)
            case .touchID:
                self.biometricButton.setTitle("Touch ID", for: .normal)
            case .none:
                self.biometricButton.setTitle("None", for: .normal)
            }
        }
    }
    
    @IBAction func biometricAction(_ sender: Any) {
        BiometricAuthenticator.requestPermission(from: self,
                                                 hasAlertIfPermissionDenied: true) { success in
            print("Success \(success)")
        }
    }
}
