//
//  UITableViewCell+Ext.swift
//  BaseProject
//
//  Created by Văn Tiến Tú on 11/7/18.
//  Copyright © 2018 Văn Tiến Tú. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class func dequeueCell(_ tableView: UITableView, indexPath: IndexPath) -> Self? {
        return tableView.dequeueCell(self, forIndexPath: indexPath)
    }
    
    class func dequeueCell(_ tableView: UITableView) -> Self? {
        return tableView.dequeueCell(self)
    }
}
