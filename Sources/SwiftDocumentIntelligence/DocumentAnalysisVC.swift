//
//  DocumentAnalysisVC.swift
//
//
//  Created by Boaz James on 28/06/2024.
//

import AVFoundation
import CoreGraphics
import UIKit
import Vision
import VisionKit

class DocumentAnalysisVC: DocumentBaseViewController {
    private var picker: UIImagePickerController!
    
    var documentType = DocumentType.ID_FRONT
    var delegate: DocumentScannerDelegate?
    
    private var validationTexts: [String] = []
    private var aspectRatio: CGFloat = 8 / 5
    
    private var frontIDDetails: FrontIDCardDetails?
    private var backIdDetails: BackIDCardDetails?
    private var licenseDetails: DrivingLicenseDetails?
    private var policeClearanceCertificateDetails: PoliceClearanceCertificateDetails?
    private var psvBadgeDetails: PSVBadgeDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.picker = UIImagePickerController()
            self.picker.delegate = self
            self.picker.presentationController?.delegate = self
            self.picker.allowsEditing = false
            self.openGallery()
        }
        
    }
    
    override func setupViews() {
        self.view.backgroundColor = .clear
        
        switch documentType {
        case .ID_FRONT:
            validationTexts = ["jamhuri ya kenya", "REPUBLIC OF KENYA"]
        case .ID_BACK:
            validationTexts = ["district", "county"]
        case .CERTIFICATE_OF_GOOD_CONDUCT:
            validationTexts = ["POLICE CLEARANCE CERTIFICATE"]
        case .PSV_BADGE:
            validationTexts = ["republic of kenya", "ntsa", "psv badge", "psu badge", "osu badge"]
        case .DRIVING_LICENSE:
            validationTexts = ["driving licence"]
        }
        
    }
    
    override func setupGestures() {
        
    }
    
    @objc private func dismissController(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true) {
            printObject(self.presentedViewController)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func openGallery() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    private func analyzeImage(image: UIImage) {
        let texts = image.getRecognizedText(recognitionLevel: .accurate)
                
        let containsValidationText = texts.contains { text in
            for validationText in self.validationTexts {
                if text.containsIgnoringCase(validationText) {
                    return true
                }
            }
            return false
        }

        if containsValidationText {
            switch self.documentType {
            case .ID_FRONT:
                let frontIdDetails = getFrontIDCardDetails(texts: texts)
                printObject("frame frontIdDetails", frontIdDetails)
                
                if let frontIdDetails = frontIdDetails {
                    if !(frontIdDetails.idNo ?? "").isEmpty && !(frontIdDetails.fullName ?? "").isEmpty && frontIdDetails.dateofBirth != nil {
                        self.frontIDDetails = frontIdDetails
                        
                        printObject("frame final frontIdDetails", frontIdDetails)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                self.delegate?.didCaptureFrontID?(image: image, details: self.frontIDDetails)
                            }
                        }
                    } else {
                        self.showDocumentAnalysisError()
                    }
                } else {
                    self.showDocumentAnalysisError()
                }
            case .ID_BACK:
                let backIdDetails = getBackIDCardDetails(texts: texts)
                printObject("frame backIdDetails", backIdDetails)
                
                if let backIdDetails = backIdDetails {
                    if !(backIdDetails.district ?? "").isEmpty {
                        self.backIdDetails = backIdDetails
                        
                        printObject("frame final backIdDetails", backIdDetails)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                self.delegate?.didCaptureBackID?(image: image, details: self.backIdDetails)
                            }
                        }
                    } else {
                        self.showDocumentAnalysisError()
                    }
                } else {
                    self.showDocumentAnalysisError()
                }
            case .DRIVING_LICENSE:
                let licenseDetails = getDrivingLicenseDetails(texts: texts)
                printObject("frame licenseDetails", licenseDetails)
                
                if let licenseDetails = licenseDetails {
                    if licenseDetails.idNo != nil && licenseDetails.licenceNo != nil && licenseDetails.expiryDate != nil {
                        self.licenseDetails = licenseDetails
                        
                        printObject("frame final licenseDetails", licenseDetails)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                self.delegate?.didCaptureDrivingLicense?(image: image, details: self.licenseDetails)
                            }
                        }
                    } else {
                        self.showDocumentAnalysisError()
                    }
                } else {
                    self.showDocumentAnalysisError()
                }
            case .CERTIFICATE_OF_GOOD_CONDUCT:
                let policeClearanceCertificateDetails = getPoliceClearanceCertificateDetails(texts: texts)
                printObject("frame policeClearanceCertificateDetails", policeClearanceCertificateDetails)
                
                if let policeClearanceCertificateDetails = policeClearanceCertificateDetails {
                    if policeClearanceCertificateDetails.idNo != nil && policeClearanceCertificateDetails.dateIssued != nil {
                        self.policeClearanceCertificateDetails = policeClearanceCertificateDetails
                        
                        printObject("frame final policeClearanceCertificateDetails", policeClearanceCertificateDetails)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                self.delegate?.didCapturePoliceClearanceCertificate?(image: image, details: self.policeClearanceCertificateDetails)
                            }
                        }
                    } else {
                        self.showDocumentAnalysisError()
                    }
                } else {
                    self.showDocumentAnalysisError()
                }
            case .PSV_BADGE:
                let psvBadgeDetails = getPSVBadgeDetails(texts: texts)
                printObject("frame psvBadgeDetails", psvBadgeDetails)
                
                if let psvBadgeDetails = psvBadgeDetails {
                    if psvBadgeDetails.licenceNo != nil && psvBadgeDetails.expiryDate != nil {
                        self.psvBadgeDetails = psvBadgeDetails
                        
                        printObject("frame final psvBadgeDetails", psvBadgeDetails)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                self.delegate?.didCapturePSVbadge?(image: image, details: self.psvBadgeDetails)
                            }
                        }
                    } else {
                        self.showDocumentAnalysisError()
                    }
                } else {
                    self.showDocumentAnalysisError()
                }
            }
        } else {
            showDocumentAnalysisError()
        }
    }
    
    private func showDocumentAnalysisError() {
        DispatchQueue.main.async {
            self.view.hideProgress()
            self.showNativeWarningAlert(title: "", message: "Could not validate document".localized, actionButtonText: "Dismiss".localized, showCancel: false) {
                self.dismissViewController()
            }
        }
    }
    
}

// Mark: UIImagePickerControllerDelegate
extension DocumentAnalysisVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.view.showProgress()
        DispatchQueue(label: "ProcessImageImage", qos: .background, attributes: .concurrent).async {
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    if let image = info[.originalImage] as? UIImage {
                        DispatchQueue(label: "ProcessImageImage", qos: .background, attributes: .concurrent).async { [weak self] in
                            self?.analyzeImage(image: image)
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        printObject("imagePickerControllerDidCancel")
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) {
                self.dismiss(animated: false)
            }
        } else {
            dismiss(animated: false)
        }
    }
}

// Mark: - UIAdaptivePresentationControllerDelegate
extension DocumentAnalysisVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: false)
    }
}
