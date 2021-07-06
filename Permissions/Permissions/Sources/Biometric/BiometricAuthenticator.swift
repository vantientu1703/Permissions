//
//  BiometricAuthenticator.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 02/07/2021.
//

import UIKit
import LocalAuthentication

class BiometricAuthenticator {
    
    enum BiometricAuthenticatorError: Swift.Error {
        case undefined
    }
    
    enum BiometryType {
        case none
        case faceID
        case touchID
        
        func toString() -> String {
            switch self {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            case .none:
                return ""
            }
        }
    }
    
    static var biometryType: BiometryType {
        if #available(iOS 11, *) {
            let _ = self.canEvaluatePolicyBiometric()
            switch LAContext().biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            case .none:
                return .none
            @unknown default:
                return .none
            }
        }
        return .none
    }
    
    static func hasFaceID() -> Bool {
        guard #available(iOS 11, *) else { return false }
        let _ = self.canEvaluatePolicyBiometric()
        return LAContext().biometryType == .faceID
    }
    
    
    static func hasTouchID() -> Bool {
        guard #available(iOS 11, *) else { return false}
        let _ = self.canEvaluatePolicyBiometric()
        return LAContext().biometryType == .touchID
    }
    
    static func hasBiometric() -> Bool {
        guard #available(iOS 11, *) else { return false }
        if self.hasTouchID() || self.hasTouchID() {
            return true
        }
        return false
    }
    
    static func canEvaluatePolicyBiometric() -> Bool {
        if #available(iOS 11, *) {
            var error: NSError?
            guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return false
            }
            if error != nil {
                return false
            }
            return true
        }
        return false
    }
    
    static func requestPermission(from viewController: UIViewController?,
                                  hasAlertIfPermissionDenied: Bool = false, completion: ((Bool) -> ())?) {
        guard #available(iOS 11, *) else {
            completion?(false)
            return
        }
        let context = LAContext()
        
        if self.canEvaluatePolicyBiometric() {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Request biometric permission") { success, error in
                if error != nil {
                    completion?(false)
                } else {
                    completion?(success)
                }
            }
        } else {
            if self.hasBiometric() {
                if hasAlertIfPermissionDenied {
                    self.presentAlertSettings(from: viewController, completion: completion)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        }
    }
    
    
    private static func presentAlertSettings(from viewController: UIViewController?,
                                             completion: ((Bool) -> ())?) {
        if #available(iOS 11, *) {
            let biometricString = self.hasFaceID() ? BiometryType.faceID.toString() : BiometryType.touchID.toString()
            let alertController = UIAlertController(title: "Settings \(biometricString)",
                                                    message: "Do you want go to Settings to turn on \(biometricString)?",
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
        } else {
            completion?(false)
        }
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
}
