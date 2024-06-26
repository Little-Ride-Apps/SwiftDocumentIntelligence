//
//  Utils.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import Foundation

func printObject(_ items: Any?...) {
    #if DEBUG
    print(Date().logDateFormat(), separator: "", terminator: ": ")

    for (idx, item) in items.enumerated() {
        if idx != items.count - 1 {
            if item != nil {
                print(item!, separator: "", terminator: ", ")
            } else {
                print(String(describing: item), separator: "    ", terminator: ", ")
            }
        } else {
            if item != nil {
                print(item!, separator: "", terminator: "\n")
            } else {
                print(String(describing: item), separator: "", terminator: "\n")
            }
        }
    }
    #endif
}

func getFrontIDCardDetails(texts: [String]) -> FrontIDCardDetails? {
    let cleanedTexts = texts.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    if cleanedTexts.isEmpty {
        return nil
    }
    
    var idNo: String?
    var dateofBirth: Date?
    var gender: String?
    var districtOfBirth: String?
    var dateIssued: Date?
    var fullName: String?
    
    if cleanedTexts.first(where: { $0.containsIgnoringCase("national") }) != nil || cleanedTexts.first(where: { $0.containsIgnoringCase("identity") }) != nil || cleanedTexts.first(where: { $0.containsIgnoringCase("card") }) != nil {
        var surname: String?
        var givenName: String?
        
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("rname") }) {
            if cleanedTexts.count > (index + 1) {
                surname = cleanedTexts[index + 1]
            }
        }
        
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("givenname") || $0.containsIgnoringCase(" name") }) {
            if cleanedTexts.count > (index + 1) {
                givenName = cleanedTexts[index + 1]
            }
        }
        
        if let surname = surname, let givenName = givenName {
            let formatter = PersonNameComponentsFormatter()
            if #available(iOS 15.0, *) {
                formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
            }
            var components = PersonNameComponents()
            components.givenName = givenName
            components.familyName = surname
            fullName = formatter.string(from: components)
        }
    } else {
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("full") || $0.containsIgnoringCase("name") }) {
            if cleanedTexts.count > (index + 1) {
                fullName = cleanedTexts[index + 1]
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("DATE OF BIRTH") || $0.containsIgnoringCase("oATE OF BIRTH") || $0.containsIgnoringCase("DATE dF BIRTH") || $0.containsIgnoringCase("oATE dF BIRTH") || $0.containsIgnoringCase("DATE OF BIRTH") }) {
        if cleanedTexts.count > (index + 1) {
            let dateText = cleanedTexts[index + 1].replacingOccurrences(of: " ", with: "")
            dateofBirth = Date.parseIdDate(dateString: dateText)
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("sex") }) {
        if cleanedTexts.count > (index + 1) {
            gender = cleanedTexts[index + 1]
        }
    }
    
    if let myGender = gender, !myGender.containsIgnoringCase("male") && !myGender.containsIgnoringCase("male") {
        gender = nil
    }
    
    if gender == nil {
        if let index = cleanedTexts.firstIndex(where: { $0.equalsIgnoringCase("male") || $0.equalsIgnoringCase("female") }) {
            if cleanedTexts.count > (index ) {
                gender = cleanedTexts[index]
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("DISTRICT OF") || $0.containsIgnoringCase("oISTRICT OF") || $0.containsIgnoringCase("DISTRICT dF") || $0.containsIgnoringCase("oISTRICT dF") || $0.containsIgnoringCase("DISTRICTOF") }) {
        if cleanedTexts.count > (index + 1) {
            districtOfBirth = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("DATE OF ISSUE") || $0.containsIgnoringCase("oATE OF ISSUE") || $0.containsIgnoringCase("DATE dF ISSUE") || $0.containsIgnoringCase("oATE dF ISSUE") || $0.containsIgnoringCase("DATEOFISSUE") }) {
        if cleanedTexts.count > (index + 1) {
            let dateText = cleanedTexts[index + 1].replacingOccurrences(of: " ", with: "")
            dateIssued = Date.parseIdDate(dateString: dateText)
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("ID NUMBER") || $0.containsIgnoringCase("iD NUMBER") || $0.containsIgnoringCase("Io NUMBER") || $0.containsIgnoringCase("ID NUMDER") || $0.containsIgnoringCase("IDNUMBER") || $0.containsIgnoringCase("iDNUMBER") || $0.containsIgnoringCase("IoNUMBER") || $0.containsIgnoringCase("IDNUMDER") || $0.containsIgnoringCase("IpNUMBER") || $0.containsIgnoringCase("Ip NUMBER") || $0.containsIgnoringCase("1D NUMBER") || $0.containsIgnoringCase("1D NUMBER") || $0.containsIgnoringCase("1o NUMBER") || $0.containsIgnoringCase("1D NUMDER") || $0.containsIgnoringCase("1DNUMBER") || $0.containsIgnoringCase("1DNUMBER") || $0.containsIgnoringCase("1oNUMBER") || $0.containsIgnoringCase("1DNUMDER") || $0.containsIgnoringCase("1pNUMBER") || $0.containsIgnoringCase("1p NUMBER") || $0.containsIgnoringCase("D NUMBER") || $0.containsIgnoringCase("D NUMBER") || $0.containsIgnoringCase("o NUMBER") || $0.containsIgnoringCase("D NUMDER") || $0.containsIgnoringCase("DNUMBER") || $0.containsIgnoringCase("DNUMBER") || $0.containsIgnoringCase("oNUMBER") || $0.containsIgnoringCase("DNUMDER") || $0.containsIgnoringCase("pNUMBER") || $0.containsIgnoringCase("p NUMBER") }) {
        if cleanedTexts.count >= index {
            let idNoText = cleanedTexts[index]
            
            if idNoText.contains(":") {
                let idNoComponents = idNoText.components(separatedBy: ":")
                
                if idNoComponents.count > 1 {
                    let myIdNo = idNoComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if myIdNo.isEmpty {
                        if cleanedTexts.count > (index + 1) {
                            idNo = cleanedTexts[index + 1]
                        }
                    } else {
                        idNo = myIdNo
                    }
                }
            } else if idNoText.hasNumber() {
                idNo = idNoText.onlyDigits()
            } else if cleanedTexts.count > (index + 1) {
                idNo = cleanedTexts[index + 1].onlyDigits()
            }
        }
    }
    
    if let idNo = idNo, let _ = Int(idNo), idNo.count >= 5 {
        
    } else {
        idNo = nil
    }
    
    return FrontIDCardDetails(idNo: idNo, dateofBirth: dateofBirth, gender: gender, districtOfBirth: districtOfBirth, dateIssued: dateIssued, fullName: fullName)
}

func getBackIDCardDetails(texts: [String]) -> BackIDCardDetails? {
    let cleanedTexts = texts.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    if cleanedTexts.isEmpty {
        return nil
    }
    
    var county: String?
    var district: String?
    var division: String?
    var location: String?
    var subLocation: String?
    
    if let index = cleanedTexts.firstIndex(where: { !$0.contains("-") && ($0.equalsIgnoringCase("county") || $0.equalsIgnoringCase("oounty") || $0.equalsIgnoringCase("0ounty") || $0.equalsIgnoringCase("c0unty")) }) {
        if cleanedTexts.count > (index + 1) {
            county = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("district") || $0.containsIgnoringCase("oistrict") || $0.containsIgnoringCase("d1str1ct") }) {
        if cleanedTexts.count > (index + 1) {
            district = cleanedTexts[index + 1]
        }
    }
    
    if (district ?? "").isEmpty {
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("-county") || $0.containsIgnoringCase("-oounty") || $0.containsIgnoringCase("-0ounty") || $0.containsIgnoringCase("-c0unty") || $0.containsIgnoringCase(" county") || $0.containsIgnoringCase(" oounty") || $0.containsIgnoringCase(" 0ounty") || $0.containsIgnoringCase(" c0unty") }) {
            if cleanedTexts.count > (index + 1) {
                district = cleanedTexts[index + 1]
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("DIVISION") || $0.containsIgnoringCase("oIVISIoN") || $0.containsIgnoringCase("D1V1S1ON") }) {
        if cleanedTexts.count > (index + 1) {
            division = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("location") || $0.containsIgnoringCase("1ocation") || $0.containsIgnoringCase("ldcat1on") ||
        $0.containsIgnoringCase("location") }) {
        if cleanedTexts.count > (index + 1) {
            location = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("-location") || $0.containsIgnoringCase("-1ocation") || $0.containsIgnoringCase("-ldcat1on") ||
        $0.containsIgnoringCase("-location") || $0.containsIgnoringCase(" location") || $0.containsIgnoringCase(" 1ocation") || $0.containsIgnoringCase(" ldcat1on") ||
        $0.containsIgnoringCase(" location") ||
        $0.containsIgnoringCase("surlocation") }) {
        if cleanedTexts.count > (index + 1) {
            subLocation = cleanedTexts[index + 1]
        }
    }
    
    return BackIDCardDetails(district: district, division: division, location: location, subLocation: subLocation, county: county)
}

func getDrivingLicenseDetails(texts: [String]) -> DrivingLicenseDetails? {
    let cleanedTexts = texts.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    if cleanedTexts.isEmpty {
        return nil
    }
    
    var surname: String?
    var otherNames: String?
    var idNo: String?
    var licenseNo: String?
    var dateofBirth: Date?
    var gender: String?
    var bloodGroup: String?
    var dateIssued: Date?
    var expiryDate: Date?
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("rname") }) {
        if cleanedTexts.count > (index + 1) {
            surname = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("other") || $0.containsIgnoringCase("0ther") || $0.containsIgnoringCase("dther") || $0.containsIgnoringCase(" name") }) {
        if cleanedTexts.count > (index + 1) {
            otherNames = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("l-") || $0.containsIgnoringCase("i-") || $0.containsIgnoringCase("1-") }) {
        if cleanedTexts.count >= index {
            let licenceText = cleanedTexts[index]
            
            if licenceText.hasNumber() {
                licenseNo = "DL-\(licenceText.onlyDigits())"
            }
        }
    }
    
    if licenseNo == nil {
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("nce no") || $0.containsIgnoringCase("noe no") || $0.containsIgnoringCase("nceno") || $0.containsIgnoringCase("nce n0") || $0.containsIgnoringCase("nce nd") }) {
            if cleanedTexts.count > (index + 1) {
                licenseNo = cleanedTexts[index + 1]
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("BIRTH") }) {
        if cleanedTexts.count > (index + 1) {
            let dateText = cleanedTexts[index + 1].replacingOccurrences(of: " ", with: "")
            dateofBirth = Date.parseIdDate(dateString: dateText)
            
            if dateofBirth == nil {
                dateofBirth = Date.parseLicenseDate(dateString: dateText)
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("sex") }) {
        if cleanedTexts.count > (index + 1) {
            gender = cleanedTexts[index + 1]
        }
    }
    
    if gender == nil {
        if let index = cleanedTexts.firstIndex(where: { $0.equalsIgnoringCase("male") || $0.equalsIgnoringCase("female") }) {
            if cleanedTexts.count > (index ) {
                gender = cleanedTexts[index]
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("blood") || $0.containsIgnoringCase("bl00d") || $0.containsIgnoringCase("b100d") || $0.containsIgnoringCase("blooo") || $0.containsIgnoringCase("bl000") || $0.containsIgnoringCase("b1000") }) {
        if cleanedTexts.count > (index + 1) {
            bloodGroup = cleanedTexts[index + 1]
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("issue") || $0.containsIgnoringCase("issue") || $0.containsIgnoringCase("1ssue") }) {
        if cleanedTexts.count > (index + 1) {
            let dateText = cleanedTexts[index + 1].replacingOccurrences(of: " ", with: "")
            dateIssued = Date.parseIdDate(dateString: dateText)
            
            if dateIssued == nil {
                dateIssued = Date.parseLicenseDate2(dateString: dateText)
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("expiry") || $0.containsIgnoringCase("exp1ry") ||
        $0.containsIgnoringCase("explry") || $0.containsIgnoringCase("exoiry") || $0.containsIgnoringCase("exdiry") }) {
        if cleanedTexts.count > (index + 1) {
            let dateText = cleanedTexts[index + 1].replacingOccurrences(of: " ", with: "")
            expiryDate = Date.parseIdDate(dateString: dateText)
            
            if expiryDate == nil {
                expiryDate = Date.parseLicenseDate2(dateString: dateText)
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("national") || $0.containsIgnoringCase("nat1onal") || $0.containsIgnoringCase("nati0nal") || $0.containsIgnoringCase("natidna1") || $0.containsIgnoringCase("natidnai") }) {
        if cleanedTexts.count >= index {
            let idNoText = cleanedTexts[index]
            
            if idNoText.hasNumber() {
                idNo = idNoText.onlyDigits()
            } else if cleanedTexts.count > (index + 1) {
                idNo = cleanedTexts[index + 1].onlyDigits()
            }
        }
    }
    
    if (idNo ?? "").isEmpty {
        if let index = cleanedTexts.firstIndex(where: { $0.count < 16 && Int($0) != nil }) {
            if cleanedTexts.count >= index {
                idNo = cleanedTexts[index]
            }
        }
    }
    
    if let idNo = idNo, let _ = Int(idNo), idNo.count >= 5 {
        
    } else {
        idNo = nil
    }
    
    return DrivingLicenseDetails(surname: surname, otherNames: otherNames, idNo: idNo, licenceNo: licenseNo, dateofBirth: dateofBirth, gender: gender, bloodGroup: bloodGroup, dateIssued: dateIssued, expiryDate: expiryDate)
}

func getPoliceClearanceCertificateDetails(texts: [String]) -> PoliceClearanceCertificateDetails? {
    let cleanedTexts = texts.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    if cleanedTexts.isEmpty {
        return nil
    }
    
    var idNo: String?
    var dateIssued: Date?
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("date") || $0.containsIgnoringCase("oate") ||
        $0.containsIgnoringCase("0ate") }) {
        let text = cleanedTexts[index]
        
        var components: [String] = []
        
        if text.contains(".") {
            components = text.components(separatedBy: ".")
        } else if text.contains(",") {
            components = text.components(separatedBy: ",")
        }
        
        if let last = components.last?.trimmingCharacters(in: .whitespacesAndNewlines), !last.isEmpty {
            dateIssued = Date.parseLicenseDate2(dateString: last)
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("ID N") || $0.containsIgnoringCase("iD N") || $0.containsIgnoringCase("Io N") }) {
        if cleanedTexts.count >= index {
            let idNoText = cleanedTexts[index]
            
            if idNoText.hasNumber() {
                idNo = idNoText.onlyDigits()
            } else if cleanedTexts.count > (index + 1) {
                idNo = cleanedTexts[index + 1].onlyDigits()
            }
        }
    }
    
    if let idNo = idNo, let _ = Int(idNo), idNo.count >= 5 {
        
    } else {
        idNo = nil
    }
    
    return PoliceClearanceCertificateDetails(idNo: idNo, dateIssued: dateIssued)
}

func getPSVBadgeDetails(texts: [String]) -> PSVBadgeDetails? {
    let cleanedTexts = texts.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    if cleanedTexts.isEmpty {
        return nil
    }
    
    var licenceNo: String?
    var expiryDate: Date?
    
    let dateTexts = texts.filter({ Date.parseLicenseDate2(dateString: $0) != nil || Date.parsePSVDate(dateString: $0) != nil })
    
    if dateTexts.count > 1 {
        let dateText = dateTexts[1]
        
        expiryDate = Date.parseLicenseDate2(dateString: dateText)
        
        if expiryDate == nil {
            expiryDate = Date.parsePSVDate(dateString: dateText)
        }
    }
    
    if expiryDate == nil {
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("expiry") || $0.containsIgnoringCase("exp1ry") ||
            $0.containsIgnoringCase("explry") || $0.containsIgnoringCase("exoiry") || $0.containsIgnoringCase("exdiry") }) {
            let text = cleanedTexts[index]
                        
            if let dateText = text.components(separatedBy: " ").first(where: { Date.parseLicenseDate2(dateString: $0) != nil || Date.parsePSVDate(dateString: $0) != nil }) {
                expiryDate = Date.parseLicenseDate2(dateString: dateText)
                
                if expiryDate == nil {
                    expiryDate = Date.parsePSVDate(dateString: dateText)
                }
            }
        }
    }
    
    if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("dl-") || $0.containsIgnoringCase("di-") || $0.containsIgnoringCase("d1-") || $0.containsIgnoringCase("ol-") || $0.containsIgnoringCase("oi-") || $0.containsIgnoringCase("o1-") }) {
        if cleanedTexts.count >= index {
            let components = cleanedTexts[index].components(separatedBy: "-")
            
            if components.count > 1, let licenceText = components.last {
                licenceNo = licenceText
            }
        }
    }
    
    if licenceNo == nil {
        if let index = cleanedTexts.firstIndex(where: { $0.containsIgnoringCase("dl n") || $0.containsIgnoringCase("di n") || $0.containsIgnoringCase("0l n") || $0.containsIgnoringCase("ol-") || $0.containsIgnoringCase("oi-") || $0.containsIgnoringCase("o1-") }) {
            if cleanedTexts.count >= (index + 1) {
                licenceNo  = cleanedTexts[index + 1]
            }
        }
    }
    
    return PSVBadgeDetails(licenceNo: licenceNo, expiryDate: expiryDate)
}

