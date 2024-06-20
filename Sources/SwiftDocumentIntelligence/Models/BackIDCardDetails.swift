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
    
    init(district: String? = nil, division: String? = nil, location: String? = nil, subLocation: String? = nil) {
        self.district = district
        self.division = division
        self.location = location
        self.subLocation = subLocation
    }
    
    public override var description: String {
        return "<BackIDCardDetails: district=\(String(describing: self.district)), division=\(String(describing: self.division)), location=\(String(describing: self.location)), subLocation=\(String(describing: self.subLocation))>"
    }
}
