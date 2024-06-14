//
//  UIImageExt.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit
import Vision

extension UIImage {
    func renderResizedImage (_ newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
        
    }
    
    func getRecognizedText(recognitionLevel: VNRequestTextRecognitionLevel,
                           minimumTextHeight: Float = 0.03125) -> [String] {
        var recognizedTexts = [String]()
        
        guard let imageCGImage = self.cgImage else { return recognizedTexts }
        let requestHandler = VNImageRequestHandler(cgImage: imageCGImage, options: [:])
        
        if #available(iOS 13.0, *) {
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                for currentObservation in observations {
                    /// The 1 in topCandidates(1) indicates that we only want one candidate.
                    /// After that we take our one and only candidate with the most confidence out of the array.
                    let topCandidate = currentObservation.topCandidates(1).first
                                        
                    if let scannedText = topCandidate {
                        recognizedTexts.append(scannedText.string)
                    }
                }
            }
            
            request.recognitionLevel = recognitionLevel
//            request.minimumTextHeight = minimumTextHeight
            
            /// Turn off language correction because otherwise this could lead to wrong results in the machineReadaleZone
            request.usesLanguageCorrection = false
            
            try? requestHandler.perform([request])
        } else {
            // Fallback on earlier versions
        }
        
        return recognizedTexts
    }
}
