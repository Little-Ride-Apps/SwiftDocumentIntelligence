//
//  DateExt.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import Foundation

extension Date {
    func logDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        return formatter.string(from: self)
    }
    
    static func parseIdDate(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: dateString)
    }
    
    static func parseLicenseDate(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    static func parseLicenseDate2(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.date(from: dateString)
    }
    
    static func parsePSVDate(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateString)
    }
}
