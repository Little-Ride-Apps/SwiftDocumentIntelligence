// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public class SwiftDocumentIntelligence {
    public static func scanDocument(parentViewController: UIViewController, documentType: DocumentType, delegate: DocumentScannerDelegate?) {
        let vc = DocumentScannerVC()
        vc.documentType = documentType
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .fullScreen
        
        parentViewController.present(navVC, animated: true)
    }
    
    public static func recognizeFace(parentViewController: UIViewController, delegate: FaceRecognitionDelegate?) {
        let vc = FaceRecognitionVC()
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .fullScreen
        
        parentViewController.present(navVC, animated: true)
    }
}
