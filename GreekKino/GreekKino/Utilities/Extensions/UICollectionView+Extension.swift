//
//  UICollectionView+Extension.swift
//  GreekKino
//
//

import UIKit

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(cellType: T.Type, reuseIdentifier: String? = nil) {
        register(cellType.nib, forCellWithReuseIdentifier: reuseIdentifier ?? cellType.identifier)
    }
    
    func dequeReusableCellOfType<T: UICollectionViewCell>(_ cellType: T.Type, reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: reuseIdentifier ?? cellType.identifier, for: indexPath) as! T
    }
}
