//
//  File.swift
//  
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

extension UIColor {
    static var labelColor: UIColor {
        if let color = UIColor(named: "LabelClor", in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        return UIColor(named: "SDKLabelColor", in: Bundle.module, compatibleWith: nil)!
    }
    
    static var primaryColor: UIColor {
        if let color = UIColor(named: "PrimaryColor", in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        return UIColor(named: "SDKPrimaryColor", in: Bundle.module, compatibleWith: nil)!
    }
    
    static var whiteColor: UIColor {
        if let color = UIColor(named: "WhiteColor", in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        return UIColor(named: "SDKWhiteColor", in: Bundle.module, compatibleWith: nil)!
    }
    
    static var backgroundColor: UIColor {
        if let color = UIColor(named: "BackgroundColor", in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        return UIColor(named: "SDKBackgroundColor", in: Bundle.module, compatibleWith: nil)!
    }
}
