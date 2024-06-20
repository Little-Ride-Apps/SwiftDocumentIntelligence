//
//  File.swift
//  
//
//  Created by Boaz James on 19/06/2024.
//

import Foundation

@objc public class DrivingLicenseDetails: NSObject {
   public var surname: String?
   public var otherNames: String?
   public var idNo: String?
   public var licenceNo: String?
   public var dateofBirth: Date?
   public var gender: String?
   public var bloodGroup: String?
   public var dateIssued: Date?
   public var expiryDate: Date?
    
    init(surname: String? = nil, otherNames: String? = nil, idNo: String? = nil, licenceNo: String? = nil, dateofBirth: Date? = nil, gender: String? = nil, bloodGroup: String? = nil, dateIssued: Date? = nil, expiryDate: Date? = nil) {
        self.surname = surname
        self.otherNames = otherNames
        self.idNo = idNo
        self.licenceNo = licenceNo
        self.dateofBirth = dateofBirth
        self.gender = gender
        self.bloodGroup = bloodGroup
        self.dateIssued = dateIssued
        self.expiryDate = expiryDate
    }
    
    public override var description: String {
        return "<DrivingLicenseDetails: surname=\(String(describing: self.surname)), otherNames=\(String(describing: self.otherNames)), idNo=\(String(describing: self.idNo)), licenceNo=\(String(describing: self.licenceNo)), dateofBirth=\(String(describing: self.dateofBirth)), gender=\(String(describing: self.gender)), bloodGroup=\(String(describing: self.bloodGroup)), dateIssued=\(String(describing: self.dateIssued)), dateIssued=\(String(describing: self.dateIssued))>"
    }
}
