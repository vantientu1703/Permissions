//
//  PhotoLibraryPermission.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 25/06/2021.
//

import UIKit
import PhotosUI

@available(iOS 10, *)
class PhotoLibraryPermission {
    
    private static let photoLibrary = PHPhotoLibrary.shared()
    
    static func requestPermission(from viewController: UIViewController?,
                                  hasAlertIfPermissionDenied: Bool = false,
                                  hasAlertIfPermissionLimited: Bool = false, completion: ((Bool) -> ())?) {
        var status: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14, *) {
            status = self.getAutherizeStatus(for: .readWrite)
        } else {
            status = self.getAutherizeStatus()
        }
        switch status {
        case .authorized:
            completion?(true)
        case .limited:
            completion?(true)
        case .denied, .restricted:
            if hasAlertIfPermissionDenied {
                self.presentAlertSettings(from: viewController, completion: completion)
            } else {
                completion?(false)
            }
        default:
            if #available(iOS 14, *) {
                self.requestPermission(accessLevel: .readWrite) { status in
                    completion?(status == .authorized || status == .limited)
                }
            } else {
                self.requestPermission { status in
                    completion?(status == .authorized)
                }
            }
        }
    }
    
    @available(iOS 14, *)
    private static func requestPermission(accessLevel: PHAccessLevel,
                                          completion: ((PHAuthorizationStatus) -> ())?) {
        PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
            completion?(status)
        }
    }
    
    
    private static func requestPermission(completion: ((PHAuthorizationStatus) -> ())?) {
        PHPhotoLibrary.requestAuthorization { status in
            completion?(status )
        }
    }
    
    @available(iOS 14, *)
    static func getAutherizeStatus(for accessLevel: PHAccessLevel) -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: accessLevel)
    }
    
    static func getAutherizeStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    private static func presentAlertSettings(from viewController: UIViewController?, completion: ((_ granted: Bool) -> ())?) {
        let alertController = UIAlertController(title: "Photos Settings",
                                                message: "Do you want go to Settings to allow access permission to Photo library?",
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
}
