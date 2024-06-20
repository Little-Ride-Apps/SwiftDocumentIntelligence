//
//  PSVBadgeDetails.swift
//
//
//  Created by Boaz James on 20/06/2024.
//

import Foundation

@objc public class PSVBadgeDetails: NSObject {
   public var licenceNo: String?
   public var expiryDate: Date?
    
    init(licenceNo: String? = nil, expiryDate: Date? = nil) {
        self.licenceNo = licenceNo
        self.expiryDate = expiryDate
    }
    
    public override var description: String {
        return "<PSVBadgeDetails: licenceNo=\(String(describing: self.licenceNo)), expiryDate=\(String(describing: self.expiryDate))>"
    }
}
