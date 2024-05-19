//
//  UITableView+Extension.swift
//  GreekKino
//
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(cellType: T.Type, reuseIdentifier: String? = nil) {
        register(cellType.nib, forCellReuseIdentifier: reuseIdentifier ?? cellType.identifier)
    }
    
    func dequeReusableCellOfType<T: UITableViewCell>(_ cellType: T.Type, reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: reuseIdentifier ?? cellType.identifier, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, reuseIdentifier: String? = nil) -> T {
        return dequeueReusableCell(withIdentifier: reuseIdentifier ?? cellType.identifier) as! T
    }
}

