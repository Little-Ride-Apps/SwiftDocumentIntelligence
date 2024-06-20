//
//  BackIDCardDetails.swift.swift
//  
//
//  Created by Boaz James on 14/06/2024.
//

import Foundation

@objc public class BackIDCardDetails: NSObject {
   public var district: String?
   public var division: String?
   public var location: String?
   public var subLocation: String?
   public var county: String?
    
    init(district: String? = nil, division: String? = nil, location: String? = nil, subLocation: String? = nil, county: String? = nil) {
        self.district = district
        self.division = division
        self.location = location
        self.subLocation = subLocation
        self.county = county
    }
    
    public override var description: String {
        return "<BackIDCardDetails: county=\(String(describing: self.county)), district=\(String(describing: self.district)), division=\(String(describing: self.division)), location=\(String(describing: self.location)), subLocation=\(String(describing: self.subLocation))>"
    }
}
