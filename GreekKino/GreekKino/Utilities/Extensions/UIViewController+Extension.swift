//
//  UIViewController+Extension.swift
//  GreekKino
//
//

import UIKit

private var activityIndicatorAssociationKey: UInt8 = 0

extension UIViewController {

    private var activityIndicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &activityIndicatorAssociationKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &activityIndicatorAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showActivityIndicator(style: UIActivityIndicatorView.Style = .large, color: UIColor? = nil) {
        if activityIndicator == nil {
            let indicator = UIActivityIndicatorView(style: style)
            indicator.color = color
            indicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            activityIndicator = indicator
        }
        activityIndicator?.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
    
    func showErrorAlert(message: String, title: String = Localized.General.error, okButtonTitle: String = Localized.General.ok) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInfoAlert(message: String, okButtonTitle: String = Localized.General.ok) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
