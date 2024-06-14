//
//  NSLayoutConstraintExt.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

extension NSLayoutConstraint {
    func activate() {
        isActive = true
    }
    
    func deactivate() {
        isActive = false
    }
}
