//
//  FrontIDCardDetails.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import Foundation

@objc public class FrontIDCardDetails: NSObject {
   public var idNo: String?
   public var dateofBirth: Date?
   public var gender: String?
   public var districtOfBirth: String?
   public var dateIssued: Date?
   public var fullName: String?
    
    init(idNo: String? = nil, dateofBirth: Date? = nil, gender: String? = nil, districtOfBirth: String? = nil, dateIssued: Date? = nil, fullName: String? = nil) {
        self.idNo = idNo
        self.dateofBirth = dateofBirth
        self.gender = gender
        self.districtOfBirth = districtOfBirth
        self.dateIssued = dateIssued
        self.fullName = fullName
    }
    
    public override var description: String {
        return "<FrontIDCardDetails: idNo=\(String(describing: self.idNo)), dateofBirth=\(String(describing: self.dateofBirth)), gender=\(String(describing: self.gender)), districtOfBirth=\(String(describing: self.districtOfBirth)), dateIssued=\(String(describing: self.dateIssued)), fullName=\(String(describing: self.fullName))>"
    }
}
