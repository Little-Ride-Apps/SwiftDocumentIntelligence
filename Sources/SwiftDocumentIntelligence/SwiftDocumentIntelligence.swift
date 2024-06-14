// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public class SwiftDocumentIntelligence {
    public static func scanDocument(parentViewController: UIViewController) {
        let vc = DocumentScannerVC()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .fullScreen
        
        parentViewController.present(navVC, animated: true)
    }
}
