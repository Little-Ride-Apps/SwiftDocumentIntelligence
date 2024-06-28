// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public class SwiftDocumentIntelligence {
    public static func scanDocument(parentViewController: UIViewController, documentType: DocumentType, delegate: DocumentScannerDelegate?, allowPickingFromGallery: Bool, showAlertOn view: UIView?) {
        if allowPickingFromGallery {
            let myView = view ?? parentViewController.view
            
            guard let myView = myView else { return }
            
            var items: [(title: String, value: String)] = []
            items.append((title: "Take a picture".localized, value: ""))
            items.append((title: "Select from gallery".localized, value: ""))
            
            parentViewController.showActionPicker(onView: myView, pickerTitle: nil, items: items) { index, item in
                if index == 0 {
                    navToDocumentScanner(parentViewController: parentViewController, documentType: documentType, delegate: delegate)
                } else {
                    navToDocumentAnalysis(parentViewController: parentViewController, documentType: documentType, delegate: delegate)
                }
            }
        } else {
            navToDocumentScanner(parentViewController: parentViewController, documentType: documentType, delegate: delegate)
        }
    }
    
    public static func recognizeFace(parentViewController: UIViewController, delegate: FaceRecognitionDelegate?) {
        let vc = FaceRecognitionVC()
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .fullScreen
        
        parentViewController.present(navVC, animated: true)
    }
    
    private static func navToDocumentScanner(parentViewController: UIViewController, documentType: DocumentType, delegate: DocumentScannerDelegate?) {
        let vc = DocumentScannerVC()
        vc.documentType = documentType
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .fullScreen
        
        parentViewController.present(navVC, animated: true)
    }
    
    private static func navToDocumentAnalysis(parentViewController: UIViewController, documentType: DocumentType, delegate: DocumentScannerDelegate?) {
        let vc = DocumentAnalysisVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.documentType = documentType
        vc.delegate = delegate
        
        parentViewController.present(vc, animated: true)
    }
}
