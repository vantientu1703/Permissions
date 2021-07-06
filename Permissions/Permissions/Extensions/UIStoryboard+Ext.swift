//
//  UIStoryboard+Ext.swift
//  BaseProject
//
//  Created by Văn Tiến Tú on 11/7/18.
//  Copyright © 2018 Văn Tiến Tú. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    enum StoryboardName: String {
        
        case splash
        case notes
        case login
        case account
        case transactions
        case noteStatistics
        case alert
        case pickerDate
        case noteInfo
        case notifications
        case search
        case main
        
        var identifier: String {
            switch self {
            case .splash:
                return "Splash"
            case .notes:
                return "Notes"
            case .login:
                return "Login"
            case .account:
                return "Account"
            case .transactions:
                return "Transactions"
            case .alert:
                return "Alert"
            case .pickerDate:
                return "PickerDate"
            case .noteStatistics:
                return "NoteStatistics"
            case .noteInfo:
                return "NoteInfo"
            case .notifications:
                return "Notifications"
            case .search:
                return "Search"
            case .main:
                return "Main"
            }
        }
    }
    
    convenience init(storyboard: StoryboardName, bundle: Bundle? = nil) {
        self.init(name: storyboard.identifier, bundle: bundle)
    }
    
    class func storyboard(_ storyboard: StoryboardName, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.identifier, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>(_ type: T.Type) -> T? {
        return instantiateViewController(withIdentifier: type.identifierString) as? T
    }
}
