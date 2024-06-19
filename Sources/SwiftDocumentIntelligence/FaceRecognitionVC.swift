//
//  FaceRecognitionVC.swift
//
//
//  Created by Boaz James on 18/06/2024.
//

import AVFoundation
import UIKit
import Vision
import VisionKit

class FaceRecognitionVC: DocumentBaseViewController {
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
        view.isHidden = true
    
        return view
    }()
    
    private let lblTitle: UILabel =  {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = .white
//        view.font = .montserratMedium()
        view.text = ""
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
        view.text = "Align your face within the rectangle and remain steady".localized
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
    
    private var drawings: [CAShapeLayer] = []
    
    private var faceTurnedToTheRight = false
    private var isTurningFaceToTheRight = false
    private var faceTurnedToTheLeft = false
    private var isTurningFaceToTheLeft = false
    private var previousYaw: Float = 0
    
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
        let aspectRatio: CGFloat = 1
        // Margin: 50
        let width = self.view.frame.size.width - (50 * 2)
        let height = width / aspectRatio
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        
        // 2 width = 200, height = 200, cornerRadius = 10
        let transparentPath = UIBezierPath(roundedRect: CGRect(x: (view.frame.size.width / 2) - (width / 2), y: (view.frame.size.height / 2) - (height / 2), width: width, height: height), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: width / 2, height: 0))
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
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                self.device = device
            } else {
                failed()
                printObject("Back camera could not be found")
                return
            }
            
            /// Enable continuous auto focus
            do {
                try self.device?.lockForConfiguration()
//                self.device?.focusMode = .continuousAutoFocus
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
    
    private func changeStrokeColor(canCapturePhoto: Bool) {
        if let layer = maskView.layer.sublayers?.first(where: { $0.name == "border" }), let shapeLayer = layer as? CAShapeLayer {
            shapeLayer.strokeColor = canCapturePhoto ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
        }
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results)
                } else {
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        guard let previewLayer = previewLayer else { return }
        self.clearDrawings()
        var hasLandmarks = false
        var hasFace = false
        var yaw: Float = 0
        
        if let observedFace = observedFaces.first {
            hasFace = true
            hasLandmarks = observedFace.landmarks != nil
            
            yaw = observedFace.yaw?.floatValue ?? 0
        }
        
        var diffYaw: Float = 0
        
        if isTurningFaceToTheRight {
            diffYaw = yaw - (previousYaw < 0 ? 0 : previousYaw)
        } else {
            if yaw >= 0 {
                diffYaw = 0
            } else if previousYaw == 0 && yaw < 0 {
                diffYaw = yaw * -1
            } else {
                diffYaw = yaw - previousYaw
            }
        }
                
        self.previousYaw = yaw
        
        /*let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            
            hasLandmarks = observedFace.landmarks != nil
            // Do not draw eyes
            /*if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }*/
            
            printObject("roll", observedFace.roll, "yaw", observedFace.yaw)
            
            yaw = observedFace.yaw?.floatValue ?? 0
            
            return newDrawings
        })*/
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if hasFace && hasLandmarks {
                if !self.faceTurnedToTheRight && !self.isTurningFaceToTheRight {
                    self.isTurningFaceToTheRight = true
                    self.lblMessage.text = "Turn your face to the right".localized
                } else if self.faceTurnedToTheRight && !self.faceTurnedToTheLeft && !self.isTurningFaceToTheLeft {
                    self.isTurningFaceToTheLeft = true
                    self.lblMessage.text = "Turn your face to the left".localized
                } else if self.isTurningFaceToTheRight && diffYaw > 0.5 {
                    self.faceTurnedToTheRight = true
                    self.isTurningFaceToTheRight = false
                    self.isTurningFaceToTheLeft = true
                    self.lblMessage.text = "Turn your face to the left".localized
                } else if self.faceTurnedToTheRight && self.isTurningFaceToTheLeft && diffYaw > 0.5 {
                    self.faceTurnedToTheLeft = true
                    self.isTurningFaceToTheLeft = false
                    self.lblMessage.text = "You can now take photo".localized
                    self.btnCapture.isEnabled = true
                    self.changeStrokeColor(canCapturePhoto: true)
                }
            } else {
                self.isTurningFaceToTheLeft = false
                self.isTurningFaceToTheRight = false
                self.faceTurnedToTheLeft = false
                self.faceTurnedToTheRight = false
                self.lblMessage.text = "Align your face within the rectangle and remain steady".localized
                self.changeStrokeColor(canCapturePhoto: false)
                self.btnCapture.isEnabled = false
                self.previousYaw = 0
            }
        }
//        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
//        self.drawings = facesBoundingBoxes
    }
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        // draw other face features here
        return faceFeaturesDrawings
    }
    
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
        
        return eyeDrawing
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
}

// Mark: - AVCapturePhotoCaptureDelegate
extension FaceRecognitionVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        
        guard let data = photo.fileDataRepresentation(), let image  = UIImage(data: data) else { return }
        
        
    }
}

// Mark: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FaceRecognitionVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            printObject("unable to get image from sample buffer")
            return
        }
        
        detectFace(in: frame)
        
        /*let ciImage = CIImage(cvPixelBuffer: frame)
        
        let image = UIImage(ciImage: ciImage)
                
        if let firstText = image.getRecognizedText(recognitionLevel: .accurate).first, firstText.containsIgnoringCase(self.firstText) {
            DispatchQueue.main.async { [weak self] in
                self?.changeStrokeColor(canReadText: true)
                self?.btnCapture.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.changeStrokeColor(canReadText: false)
                self?.btnCapture.isEnabled = false
            }
        }*/

    }
}
