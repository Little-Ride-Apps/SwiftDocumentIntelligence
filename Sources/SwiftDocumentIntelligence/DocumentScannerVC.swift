//
//  File.swift
//  
//
//  Created by Boaz James on 14/06/2024.
//

import AVFoundation
import UIKit
import Vision
import VisionKit

class DocumentScannerVC: DocumentBaseViewController {
    private let previewContainer: UIView =  {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    
        return view
    }()
    
    private let overlayView: UIView =  {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    
        return view
    }()
    
    private let maskView: UIView =  {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    
        return view
    }()
    
    private let btnClose: IconButton =  {
        let view = IconButton(imgSize: 20, size: CGSize(width: 40, height: 40))
        view.customBackgroundColor = .clear
        view.tintColor = .whiteColor
        view.imgName = "close"
    
        return view
    }()
    
    private let btnFlash: IconButton =  {
        let view = IconButton(imgSize: 30, size: CGSize(width: 40, height: 40))
        view.customBackgroundColor = .clear
        view.tintColor = .whiteColor
        view.imgName = "ic_flash_off"
    
        return view
    }()
    
    private let lblTitle: UILabel =  {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = .white
//        view.font = .montserratMedium()
        view.text = "ID Front"
        view.numberOfLines = 0
        view.textAlignment = .center
    
        return view
    }()
    
    private let lblMessage: UILabel =  {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = .white
//        view.font = .montserratMedium()
        view.text = "Align your ID within the rectangle"
        view.numberOfLines = 0
        view.textAlignment = .center
    
        return view
    }()
    
    private let btnCaptureContainerView: UIView =  {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .whiteColor
        view.sdkCornerRadius = 36
        view.isHidden = true
    
        return view
    }()
    
    private let btnCapture: IconButton =  {
        let view = IconButton(imgSize: 0, size: CGSize(width: 64, height: 64))
        view.customBackgroundColor = .systemBlue
        view.disabledBackgroundColor = .lightGray
        view.highlightBackgroundColor = .lightGray
        view.sdkCornerRadius = 30
        view.sdkBorderColor = .labelColor
        view.sdkBorderWidth = 2
        view.isEnabled = false
    
        return view
    }()
    
    private var device: AVCaptureDevice?
    private var output = AVCaptureMetadataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput = AVCapturePhotoOutput()
    private var photoSettings: AVCapturePhotoSettings?
    private var captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var code: String?
    
    private var scannedCode = UILabel()
    
    private let sessionQueue = DispatchQueue(label: "Capture Session Queue")
    private var boundingBox = CAShapeLayer()
    private var resetTimer: Timer?
    private var isCapturingPhoto = false
    
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
        
        checkCameraSettings()
        
        setupMask()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if (captureSession.isRunning == false) {
            startCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @objc func willEnterForeground() {
//       icFlash?.image = UIImage(named: "ic_flash_off")
    }
    
    @objc func willEnterBackground() {
        btnFlash.imgName = "ic_flash_off"
    }
    
    override func setupViews() {
        self.view.addSubview(overlayView)
        self.view.addSubview(previewContainer)
        self.view.addSubview(maskView)
        self.view.addSubview(btnClose)
        self.view.addSubview(btnFlash)
        self.view.addSubview(lblTitle)
        self.view.addSubview(lblMessage)
        self.view.addSubview(btnCaptureContainerView)
        btnCaptureContainerView.addSubview(btnCapture)
        
        switch documentType {
        case .ID_FRONT:
            validationTexts = ["jamhuri ya kenya", "REPUBLIC OF KENYA"]
            aspectRatio = 8 / 5
            lblTitle.text = "ID Front".localized
            lblMessage.text = "Align your ID within the rectangle".localized
        case .ID_BACK:
            validationTexts = ["district", "county"]
            aspectRatio = 8 / 5
            lblTitle.text = "ID Back".localized
            lblMessage.text = "Align your ID within the rectangle".localized
        case .CERTIFICATE_OF_GOOD_CONDUCT:
            validationTexts = ["POLICE CLEARANCE CERTIFICATE"]
            aspectRatio = 70 / 99
            lblTitle.text = "Police clearance certificate".localized
            lblMessage.text = "Align your certificate within the rectangle".localized
        case .PSV_BADGE:
            validationTexts = ["republic of kenya", "ntsa", "psv badge", "psu badge", "osu badge"]
            aspectRatio = 8 / 5
            lblTitle.text = "PSV badge".localized
            lblMessage.text = "Align your PSV badge within the rectangle".localized
        case .DRIVING_LICENSE:
            validationTexts = ["driving licence"]
            aspectRatio = 8 / 5
            lblTitle.text = "Driving Licence".localized
            lblMessage.text = "Align your licence within the rectangle".localized
        }
        
    }
    
    override func setupSharedContraints() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide
        
        overlayView.pinToView(parentView: self.view)
        
        previewContainer.pinToView(parentView: self.view)
        
        maskView.pinToView(parentView: self.view)
        
        NSLayoutConstraint.activate([
            btnClose.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            btnClose.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15)
        ])
        
        NSLayoutConstraint.activate([
            btnFlash.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            btnFlash.topAnchor.constraint(equalTo: btnClose.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lblTitle.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
            lblTitle.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            lblTitle.topAnchor.constraint(equalTo: btnFlash.bottomAnchor, constant: aspectRatio > 1 ? 40 : 10)
        ])
        
        NSLayoutConstraint.activate([
            lblMessage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
            lblMessage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            lblMessage.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 10)
        ])
        
        btnCaptureContainerView.applyAspectRatio(aspectRation: 1)
        NSLayoutConstraint.activate([
            btnCaptureContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnCaptureContainerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            btnCaptureContainerView.heightAnchor.constraint(equalToConstant: 72)
        ])
        
        btnCapture.centerOnView(parentView: btnCaptureContainerView)
        
        overlayView.layoutIfNeeded()
        previewContainer.layoutIfNeeded()
        maskView.layoutIfNeeded()
    }
    
    override func setupGestures() {
        btnClose.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        btnFlash.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        btnCapture.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    }
    
    @objc private func dismissController(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true) {
            printObject(self.presentedViewController)
        }
    }
    
    @objc private func toggleFlash() {
        guard let device = device else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == AVCaptureDevice.TorchMode.off {
                    device.torchMode = .on
                    btnFlash.imgName = "ic_flash_on"
                } else {
                    device.torchMode = .off
                    btnFlash.imgName = "ic_flash_off"
                }
                
                device.unlockForConfiguration()
            } catch {
                printObject("Torch could not be used")
            }
        } else {
            printObject("Torch is not available")
        }
    }
    
    private func setupMask() {
        // Margin: 20
        let width = self.view.frame.size.width - ((aspectRatio < 1 ? 50 : 20) * 2)
        let height = width / aspectRatio
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        
        // 2 width = 200, height = 200, cornerRadius = 10
        let transparentPath = UIBezierPath(roundedRect: CGRect(x: (view.frame.size.width / 2) - (width / 2), y: (view.frame.size.height / 2) - (height / 2), width: width, height: height), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 0))
        overlayPath.append(transparentPath)
        overlayPath.usesEvenOddFillRule = true
        
        // 3
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.primaryColor.cgColor
        
        // 4
        maskView.layer.addSublayer(fillLayer)
        let cornerLayer = CAShapeLayer()
        cornerLayer.path = overlayPath.cgPath
        cornerLayer.fillColor = UIColor.clear.cgColor
        maskView.layer.addSublayer(fillLayer)
        
        // Border
        let borderLayer = CAShapeLayer()
        borderLayer.path = transparentPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.systemRed.cgColor
        borderLayer.lineWidth = 2
        borderLayer.name = "border"
        maskView.layer.addSublayer(borderLayer)
    }
    
    /// Setup and start the captureSession
    func setupCaptureSession() {
//        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        if captureSession.canSetSessionPreset(.photo) {
          captureSession.sessionPreset = .photo
        }

        setupInputs()
        setupOutput()

        captureSession.commitConfiguration()
        setupPreviewLayer()
//        setupBoundingBox()

        /// Start of the capture session must be executed in the background thread
        /// by our extension function so the UI is not blocked in the main thread
        startCaptureSession()
    }
    
    // Setup the captureSession input which is the camera feed
    private func setupInputs() {
        sessionQueue.sync {
            /// Get back camera
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                self.device = device
            } else {
                failed()
                printObject("Back camera could not be found")
                return
            }
            
            /// Enable continuous auto focus
            do {
                try self.device?.lockForConfiguration()
                self.device?.focusMode = .continuousAutoFocus
                self.device?.unlockForConfiguration()
            } catch {
                printObject("Camera lockConfiguration failed")
                failed()
                return
            }
            
            /// Create input from our device
            guard let device = self.device, let backCameraInput = try? AVCaptureDeviceInput(device: device) else {
                printObject("Could not create device input from back camera")
                failed()
                return
            }
            
            if !captureSession.canAddInput(backCameraInput) {
                printObject("could not add back camera input to capture session")
                failed()
                return
            }
            
            captureSession.addInput(backCameraInput)
        }
    }
    
    /// Setup the captureSession output which is responsible for the generated pictures
    private func setupOutput() {
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Video Frames
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        guard let connection = videoOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = previewContainer.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        previewContainer.layer.addSublayer(previewLayer!)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // This is the delegate'smethod that is called when a code is read
        
        printObject(metadataObjects)
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            scannedCode.text = code
            
        }
    }
    
    private func checkCameraSettings() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: setupCaptureSession()
        case .restricted, .denied:
            alertCameraAccessNeeded()
        @unknown default:
            failed()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
            guard accessGranted == true else {
                DispatchQueue.main.async {
                    self.alertCameraAccessNeeded()
                }
                return
            }
            DispatchQueue.main.async {
                self.setupCaptureSession()
            }
        })
    }
    
    private func alertCameraAccessNeeded() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        
        showNativeWarningAlert(title: "Camera access denied/restricted".localized, message: "You won't be able to scan document unless you allow access to the Camera. Click settings to turn on camera access.".localized, actionButtonText: "Go to Settings".localized) {
            UIApplication.shared.open(url)
        }
        
    }
    
    private func startCaptureSession() {
        DispatchQueue(label: "captureSession", qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    private func failed() {
        showNativeWarningAlert(title: "Scanning not supported".localized, message: "Your device does not support scanning document. Please use a device with a camera.".localized, showCancel: false) {
            
        }
    }
    
    @objc private func capturePhoto() {
        /*var photoSettings: AVCapturePhotoSettings?
        
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        
        guard let photoSettings = photoSettings else { return }*/
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
                
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    private func changeStrokeColor(canReadText: Bool) {
        if let layer = maskView.layer.sublayers?.first(where: { $0.name == "border" }), let shapeLayer = layer as? CAShapeLayer {
            shapeLayer.strokeColor = canReadText ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
        }
    }
    
}

// Mark: - AVCapturePhotoCaptureDelegate
extension DocumentScannerVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        
//        guard let cgImage = photo.cgImageRepresentation() else { return }
//        let image = UIImage(cgImage: cgImage)
        guard let data = photo.fileDataRepresentation(), let image  = UIImage(data: data) else { return }
        
        printObject("didFinishProcessingPhoto")
        
        self.dismiss(animated: true) {
            switch self.documentType {
            case .ID_FRONT:
                self.delegate?.didCaptureFrontID?(image: image, details: self.frontIDDetails)
            case .ID_BACK:
                self.delegate?.didCaptureBackID?(image: image, details: self.backIdDetails)
            case .CERTIFICATE_OF_GOOD_CONDUCT:
                self.delegate?.didCapturePoliceClearanceCertificate?(image: image, details: self.policeClearanceCertificateDetails)
            case .DRIVING_LICENSE:
                self.delegate?.didCaptureDrivingLicense?(image: image, details: self.licenseDetails)
            case .PSV_BADGE:
                self.delegate?.didCapturePSVbadge?(image: image, details: self.psvBadgeDetails)
            }
        }
        
//        let texts = image.getRecognizedText(recognitionLevel: .accurate)
        
//        printObject("getRecognizedText", texts)
    }
}

// Mark: - AVCaptureVideoDataOutputSampleBufferDelegate
extension DocumentScannerVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !self.isCapturingPhoto else { return }
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            printObject("unable to get image from sample buffer")
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: frame)
        
        let image = UIImage(ciImage: ciImage)
        
        let texts = image.getRecognizedText(recognitionLevel: .accurate)
        
        printObject("frame texts", texts)
        
        let containsValidationText = texts.contains { text in
            for validationText in self.validationTexts {
                if text.containsIgnoringCase(validationText) {
                    return true
                }
            }
            return false
        }

        if containsValidationText {
            DispatchQueue.main.async { [weak self] in
                self?.changeStrokeColor(canReadText: true)
                self?.btnCapture.isEnabled = true
            }
            
            switch self.documentType {
            case .ID_FRONT:
                let frontIdDetails = getFrontIDCardDetails(texts: texts)
                printObject("frame frontIdDetails", frontIdDetails)
                
                if let frontIdDetails = frontIdDetails {
                    if !(frontIdDetails.idNo ?? "").isEmpty && !(frontIdDetails.fullName ?? "").isEmpty && frontIdDetails.dateofBirth != nil {
                        self.frontIDDetails = frontIdDetails
                        
                        printObject("frame final frontIdDetails", frontIdDetails)
                        
                        self.isCapturingPhoto = true
                        DispatchQueue(label: "capturePhoto", qos: .background).async { [weak self] in
                            self?.capturePhoto()
                        }
                    }
                }
            case .ID_BACK:
                let backIdDetails = getBackIDCardDetails(texts: texts)
                printObject("frame backIdDetails", backIdDetails)
                
                if let backIdDetails = backIdDetails {
                    if !(backIdDetails.district ?? "").isEmpty {
                        self.backIdDetails = backIdDetails
                        
                        printObject("frame final backIdDetails", backIdDetails)
                        
                        self.isCapturingPhoto = true
                        DispatchQueue(label: "capturePhoto", qos: .background).async { [weak self] in
                            self?.capturePhoto()
                        }
                    }
                }
            case .DRIVING_LICENSE:
                let licenseDetails = getDrivingLicenseDetails(texts: texts)
                printObject("frame licenseDetails", licenseDetails)
                
                if let licenseDetails = licenseDetails {
                    if licenseDetails.idNo != nil && licenseDetails.licenceNo != nil && licenseDetails.expiryDate != nil {
                        self.licenseDetails = licenseDetails
                        
                        printObject("frame final licenseDetails", licenseDetails)
                        
                        self.isCapturingPhoto = true
                        DispatchQueue(label: "capturePhoto", qos: .background).async { [weak self] in
                            self?.capturePhoto()
                        }
                    }
                }
            case .CERTIFICATE_OF_GOOD_CONDUCT:
                let policeClearanceCertificateDetails = getPoliceClearanceCertificateDetails(texts: texts)
                printObject("frame policeClearanceCertificateDetails", policeClearanceCertificateDetails)
                
                if let policeClearanceCertificateDetails = policeClearanceCertificateDetails {
                    if policeClearanceCertificateDetails.idNo != nil && policeClearanceCertificateDetails.dateIssued != nil {
                        self.policeClearanceCertificateDetails = policeClearanceCertificateDetails
                        
                        printObject("frame final policeClearanceCertificateDetails", policeClearanceCertificateDetails)
                        
                        self.isCapturingPhoto = true
                        DispatchQueue(label: "capturePhoto", qos: .background).async { [weak self] in
                            self?.capturePhoto()
                        }
                    }
                }
            case .PSV_BADGE:
                let psvBadgeDetails = getPSVBadgeDetails(texts: texts)
                printObject("frame psvBadgeDetails", psvBadgeDetails)
                
                if let psvBadgeDetails = psvBadgeDetails {
                    if psvBadgeDetails.licenceNo != nil && psvBadgeDetails.expiryDate != nil {
                        self.psvBadgeDetails = psvBadgeDetails
                        
                        printObject("frame final psvBadgeDetails", psvBadgeDetails)
                        
                        self.isCapturingPhoto = true
                        DispatchQueue(label: "capturePhoto", qos: .background).async { [weak self] in
                            self?.capturePhoto()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.changeStrokeColor(canReadText: false)
                self?.btnCapture.isEnabled = false
            }
        }

    }
}

// Mark: - DocumentScannerDelegate
@objc public protocol DocumentScannerDelegate {
    @objc optional func didCaptureFrontID(image: UIImage, details: FrontIDCardDetails?)
    
    @objc optional func didCaptureBackID(image: UIImage, details: BackIDCardDetails?)
    
    @objc optional func didCaptureDrivingLicense(image: UIImage, details: DrivingLicenseDetails?)
    
    @objc optional func didCapturePoliceClearanceCertificate(image: UIImage, details: PoliceClearanceCertificateDetails?)
    
    @objc optional func didCapturePSVbadge(image: UIImage, details: PSVBadgeDetails?)
}
