//
//  Localizable.swift.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

extension String {
    
    var localized: String {
        return Bundle.module.localizedString(forKey: self, value: self, table: "Localizable")
    }
}
