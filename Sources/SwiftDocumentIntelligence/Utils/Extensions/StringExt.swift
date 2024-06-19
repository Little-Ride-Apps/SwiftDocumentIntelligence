//
//  StringExt.swift
//
//
//  Created by Boaz James on 18/06/2024.
//

import Foundation

extension String {
    func containsIgnoringCase(_ string: String) -> Bool {
        if let _ = self.range(of: string, options: .caseInsensitive) {
            return true
        }
        
        return false
    }
    
    func equalsIgnoringCase(_ string: String) -> Bool {
        return self.caseInsensitiveCompare(string) == .orderedSame
    }
}
