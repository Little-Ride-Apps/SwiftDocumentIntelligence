//
// PoliceClearanceCertificateDetails.swift
//  
//
//  Created by Boaz James on 20/06/2024.
//

import Foundation

@objc public class PoliceClearanceCertificateDetails: NSObject {
   public var idNo: String?
   public var dateIssued: Date?
    
    init(idNo: String? = nil, dateIssued: Date? = nil) {
        self.idNo = idNo
        self.dateIssued = dateIssued
    }
    
    public override var description: String {
        return "<PoliceClearanceCertificateDetails: idNo=\(String(describing: self.idNo)), dateIssued=\(String(describing: self.dateIssued))>"
    }
}
