//
//  UITableViewHeaderFooterView+Ext.swift
//  BaseProject
//
//  Created by Văn Tiến Tú on 11/7/18.
//  Copyright © 2018 Văn Tiến Tú. All rights reserved.
//

import UIKit

extension UITableViewHeaderFooterView {
    
    class var nib: UINib {
        return UINib(nibName: self.identifierString, bundle: nil)
    }
    
    class func dequeueHeaderFooter(_ tableView: UITableView) -> Self? {
        return tableView.dequeueHeaderFooter(self)
    }
}
