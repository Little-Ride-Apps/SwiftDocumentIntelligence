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
    
        return view
    }()
    
    private let btnCapture: IconButton =  {
        let view = IconButton(imgSize: 0, size: CGSize(width: 64, height: 64))
        view.customBackgroundColor = .clear
        view.sdkCornerRadius = 30
        view.sdkBorderColor = .labelColor
        view.sdkBorderWidth = 2
    
        return view
    }()
    
    private var device: AVCaptureDevice?
    private var output = AVCaptureMetadataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput = AVCapturePhotoOutput()
    private var photoSettings: AVCapturePhotoSettings?
    private var captureSession = AVCaptureSession()
    
    
    private var code: String?
    
    private var scannedCode = UILabel()
    
    private let sessionQueue = DispatchQueue(label: "Capture Session Queue")
    private var boundingBox = CAShapeLayer()
    private var resetTimer: Timer?
    
    var validate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCameraSettings()
        
        setupMask()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            startCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
            lblTitle.topAnchor.constraint(equalTo: btnFlash.bottomAnchor, constant: 40)
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
        // 1
        let aspectRatio: CGFloat = 8 / 5
        // Margin: 30
        let width = self.view.frame.size.width - (30 * 2)
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
        
        maskView.layer.addSublayer(cornerLayer)
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
        var photoSettings: AVCapturePhotoSettings?
        
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        
        guard let photoSettings = photoSettings else { return }
                
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

// Mark: - AVCaptureMetadataOutputObjectsDelegate
/*extension DocumentScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            //            self.resultsLabel.text = object.stringValue
            printObject("code: \(object.stringValue)")
            
            guard let transformedObject = previewLayer!.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            if let code = object.stringValue {
                updateBoundingBox(transformedObject.corners)
                hideBoundingBox(after: 0.25)
                self.captureSession.stopRunning()
                self.qrCodeFound(code: code)
            }
        }
    }
}*/

// Mark: - AVCapturePhotoCaptureDelegate
extension DocumentScannerVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        
        guard let data = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        
        printObject("didFinishProcessingPhoto")
        
        let texts = image?.getRecognizedText(recognitionLevel: .accurate)
        
        printObject("getRecognizedText", texts)
    }
}
