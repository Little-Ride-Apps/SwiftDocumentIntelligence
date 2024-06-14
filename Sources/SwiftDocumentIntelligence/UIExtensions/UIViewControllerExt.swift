//
//  UIViewControllerExt.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

extension UIViewController {
    func showNativeWarningAlert(title: String = "", message: String, actionButtonText: String = "OK".localized, dismissButtonText: String = "Dismiss".localized, showCancel: Bool = true, actionButtonClosure:  (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if showCancel {
            alert.addAction(UIAlertAction(title: dismissButtonText, style: .destructive, handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: actionButtonText, style: .default, handler: { (action) in
            actionButtonClosure?()
        }))
        
        self.present(alert, animated: true)
    }
}
