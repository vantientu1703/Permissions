//
//  PhotoLibraryPermission.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 25/06/2021.
//

import UIKit
import PhotosUI

@available(iOS 10, *)
class PhotoLibraryPermission: NSObject {
    
    enum TPHAuthorizationStatus : Int {

        case notDetermined = 0 // User has not yet made a choice with regards to this application

        case restricted = 1 // This application is not authorized to access photo data.

        // The user cannot change this application’s status, possibly due to active restrictions
        //   such as parental controls being in place.
        case denied = 2 // User has explicitly denied this application access to photos data.

        case authorized = 3 // User has authorized this application to access photos data.

        case limited = 4 // User has authorized this application for limited photo library access. Add PHPhotoLibraryPreventAutomaticLimitedAccessAlert = YES to the application's Info.plist to prevent the automatic alert to update the users limited library selection. Use -[PHPhotoLibrary(PhotosUISupport) presentLimitedLibraryPickerFromViewController:] from PhotosUI/PHPhotoLibrary+PhotosUISupport.h to manually present the limited library picker.
    }
    
    private static let photoLibrary = PHPhotoLibrary.shared()
    static let shared = PhotoLibraryPermission()
    private var didSelectPhotos: (() -> ())?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func onDidSelectPhotos(completion: (() -> ())?) -> Self {
        self.didSelectPhotos = completion
        return self
    }
    
    @available(iOS 14, *)
    func managePhotos(from viewController: UIViewController) {
        if PhotoLibraryPermission.getAutherizeStatus() == .limited {
            let actionSheet = UIAlertController(title: "Photos Setting",
                                                message: "Select more photos or go to Settings to allow access to all photos.",
                                                preferredStyle: .actionSheet)
            let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                                   style: .default) { (_) in
                // Show limited library picker
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
            }
            actionSheet.addAction(selectPhotosAction)
            
            let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                      style: .default) {(_) in
                PhotoLibraryPermission.gotoSettings()
            }
            actionSheet.addAction(allowFullAccessAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(cancelAction)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11, execute: { [weak viewController] in
                viewController?.present(actionSheet, animated: true, completion: nil)
            })
        }
    }
    
    static func requestPermission(from viewController: UIViewController?,
                                  hasAlertIfPermissionDenied: Bool = false, completion: ((Bool) -> ())?) {
        let status = self.getAutherizeStatus()
        switch status {
        case .authorized, .limited:
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
    
    static func getAutherizeStatus() -> TPHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite).toTPHAuthorizationStatus()
        }
        return PHPhotoLibrary.authorizationStatus().toTPHAuthorizationStatus()
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

extension PhotoLibraryPermission: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.didSelectPhotos?()
    }
}

extension PHAuthorizationStatus {
    func toTPHAuthorizationStatus() -> PhotoLibraryPermission.TPHAuthorizationStatus {
        switch self {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
