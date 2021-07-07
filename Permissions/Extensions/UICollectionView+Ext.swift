//
//  UICollectionView+Ext.swift
//  BaseProject
//
//  Created by Văn Tiến Tú on 11/7/18.
//  Copyright © 2018 Văn Tiến Tú. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func registerCellByNib<T: UICollectionViewCell>(_ type: T.Type) {
        register(type.nib, forCellWithReuseIdentifier: type.identifier)
    }
    
    func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: type.identifier)
    }
    
    func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as? T
    }
    
    func dequeueHeader<T: UICollectionReusableView>(_ type: T.Type, ofKind elementKind: String, for indexPath: IndexPath) -> T? {
        return self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: type.identifierString, for: indexPath) as? T
    }
    
    func cellForItem<T: UICollectionViewCell>(_ type: T.Type, at indexPath: IndexPath) -> T? {
        return self.cellForItem(at: indexPath) as? T
    }
    
    func headerForSection<T: UICollectionReusableView>(_ type: T.Type, forElementKind elementKind: String, at indexPath: IndexPath) -> T? {
        return self.supplementaryView(forElementKind: elementKind, at: indexPath) as? T
    }
}
