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
    
    func showActionPicker(onView view: UIView, pickerTitle: String?, items: [(title: String, value: String)], actionButtonClosure:  ((_ index: Int, _ item: (title: String, value: String)) -> Void)? = nil) {
        self.view.endEditing(true)
        if !items.isEmpty {
            let vc = UIAlertController(title: pickerTitle, message: nil, preferredStyle: .actionSheet)
            for (index, item) in items.enumerated() {
                let alertAction = UIAlertAction(title: item.title, style: .default) { (alertAction: UIAlertAction!) in
                    actionButtonClosure?(index, item)
                }
                vc.addAction(alertAction)
            }
            
            let cancelAction = UIAlertAction(title: "Dismiss".localized, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            vc.addAction(cancelAction)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                vc.popoverPresentationController?.sourceView = view
                vc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.size.width / 6.0, y: view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            }
            self.present(vc, animated: true)
        }
    }
}
