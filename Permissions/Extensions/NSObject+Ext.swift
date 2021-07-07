//
//  NSObject+Ext.swift
//  BaseProject
//
//  Created by Văn Tiến Tú on 11/7/18.
//  Copyright © 2018 Văn Tiến Tú. All rights reserved.
//

import UIKit

// MARK: - Response Identifier
protocol ResponseIdentifier {}

extension ResponseIdentifier {
    var identifierString: String {
        return String(describing: type(of: self))
    }
    
    static var identifierString: String {
        return String(describing: self)
    }
}

extension NSObject: ResponseIdentifier {}

extension NSObject {

}
