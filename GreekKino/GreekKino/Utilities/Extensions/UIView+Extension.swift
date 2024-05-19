//
//  UIView+Extension.swift
//  GreekKino
//
//

import UIKit

extension UIView {
    static var viewFromNib: Self? {
        return nib.instantiate(withOwner: nil, options: nil).first as? Self
    }
    
    static func viewFromNib(owner: Any) -> UIView {
        return (Bundle.main.loadNibNamed(identifier, owner: owner, options: nil)?.first as! UIView)
    }
    
    static var identifier: String {
        return String(describing: self.classForCoder())
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
