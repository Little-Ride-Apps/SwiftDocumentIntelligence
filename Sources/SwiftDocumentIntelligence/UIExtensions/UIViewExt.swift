//
//  UIViewExt   .swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

@IBDesignable extension UIView {
    @IBInspectable var sdkBorderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var sdkBorderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var sdkCornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

extension UIView {
    func pinToView(parentView: UIView, leading: Bool = true, trailing: Bool = true, top: Bool = true, bottom: Bool = true) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = leading
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = trailing
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = top
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = bottom
    }
    
    func pinToView(parentView: UIView, constant: CGFloat, leading: Bool = true, trailing: Bool = true, top: Bool = true, bottom: Bool = true) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant).isActive = leading
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -constant).isActive = trailing
        self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = top
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -constant).isActive = bottom
    }
    
    func centerOnView(parentView: UIView, centerX: Bool = true, centerY: Bool = true) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = centerX
        self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = centerY
    }
    
    func applyAspectRatio(aspectRation: CGFloat) {
        NSLayoutConstraint(item: self,
                           attribute: NSLayoutConstraint.Attribute.width,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self,
                           attribute: NSLayoutConstraint.Attribute.height,
                           multiplier: aspectRation,
                           constant: 0).isActive = true
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    
    func showProgress(backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)) {
        self.hideProgress()
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        let spinnerView = UIView()
        spinnerView.tag = self.tag
        spinnerView.backgroundColor = backgroundColor
        spinnerView.isUserInteractionEnabled = true
        spinnerView.layer.cornerRadius = self.layer.cornerRadius
        var style: UIActivityIndicatorView.Style {
            if #available(iOS 13.0, *) {
                return UIActivityIndicatorView.Style.medium
            }
            
            return UIActivityIndicatorView.Style.gray
        }
        let indicator = UIActivityIndicatorView.init(style: style)
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        indicator.color = .primaryColor
        indicator.startAnimating()
        DispatchQueue.main.async {
            spinnerView.addSubview(indicator)
            indicator.centerOnView(parentView: spinnerView)
            self.addSubview(spinnerView)
            spinnerView.pinToView(parentView: self)
        }
        
    }
    
    func hideProgress() {
        DispatchQueue.main.async {
            if let view = self.subviews.filter({ $0.tag == self.tag}).first {
                view.removeFromSuperview()
            }
        }
    }
}
