import Foundation
import AVFoundation
import UIKit

class CameraConfiguration: NSObject {
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    public enum OutputType {
        case photo
        case video
    }
    
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var audioDevice: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode: AVCaptureDevice.FlashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    var videoOutput: AVCaptureMovieFileOutput?
    var audioInput: AVCaptureDeviceInput?
    var outputType: OutputType?
    
    var url: URL!
}
// MARK: Extension 1

extension CameraConfiguration {
    
    func setup(iso: Float = 0, time: Int = 0, handler: @escaping (Error?)-> Void ) {
        
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
            
            let cameras = (session.devices.compactMap{$0})

            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            self.audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        }
        
        //Configure inputs with capture session
        //only allows one camera-based input per capture session at a time.
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            
            captureSession.sessionPreset =  .hd4K3840x2160
            print(rearCamera?.formats.first?.minISO ?? 0)
            print(rearCamera?.formats.first?.maxISO ?? 0)
            
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            if iso > 0 && time > 0 {
                try rearCamera?.lockForConfiguration()
                rearCamera?.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: Int32(time)), iso: iso, completionHandler: nil)
                rearCamera?.unlockForConfiguration()
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(self.rearCameraInput!) {
                    
                    captureSession.addInput(self.rearCameraInput!)
                    self.currentCameraPosition = .rear
                } else {
                    print("error 1")
                    throw CameraControllerError.inputsAreInvalid
                }
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                    self.currentCameraPosition = .front
                } else {
                    print("error 2")
                    throw CameraControllerError.inputsAreInvalid
                }
            }
                
            else {
                throw CameraControllerError.noCamerasAvailable
            }
            
//            if let audioDevice = self.audioDevice {
//                self.audioInput = try AVCaptureDeviceInput(device: audioDevice)
//                if captureSession.canAddInput(self.audioInput!) {
//                    captureSession.addInput(self.audioInput!)
//                } else {
//                    print("error 3")
//                    throw CameraControllerError.inputsAreInvalid
//                }
//            }
        }
        
        //Configure outputs with capture session
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg ])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.automaticallyConfiguresCaptureDeviceForWideColor = false
                captureSession.stopRunning()
                captureSession.addOutput(self.photoOutput!)
            }
            self.outputType = .photo
            captureSession.startRunning()
        }
        
        // -MARK: CONFIGURE Video Output
        
        func configureVideoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            self.videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(self.videoOutput!) {
                captureSession.addOutput(self.videoOutput!)
            }
            
        }
        
        DispatchQueue(label: "setup").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
//                try configurePhotoOutput()
                try configureVideoOutput()
            } catch {
                DispatchQueue.main.async {
                    handler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                handler(nil)
            }
        }
    }
    
    func displayPreview(_ view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width , height: view.frame.height)
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func recordVideo(completion: @escaping (URL?, Error?)-> Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        // MARK: Camera Settings
        print("video codec types = \(self.videoOutput!.availableVideoCodecTypes)")
        self.videoOutput?.setOutputSettings(
            [AVVideoCodecKey : AVVideoCodecType.hevc,
             AVVideoCompressionPropertiesKey: [
//                AVVideoAverageBitRateKey: 20 * 1024 * 1024,
                AVVideoQualityKey: 1,
             ]
            ],
                                            for: (self.videoOutput?.connection(with: .video))!)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("path = \(paths)")
        let fileUrl = paths[0].appendingPathComponent("\(LocalStorage.getString(key: LocalStorage.currentSession)).mov")
        try? FileManager.default.removeItem(at: fileUrl)
        url = fileUrl
//        print("URL = \(url)")
        videoOutput!.startRecording(to: fileUrl, recordingDelegate: self)
        self.videoRecordCompletionBlock = completion
    }
    
    func stopRecording(completion: @escaping (Error?)->Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completion(CameraControllerError.captureSessionIsMissing)
            return
        }
        self.videoOutput?.stopRecording()
        
    }
    
    func separateVideo() {
        let vs = VideoSeparator()
        vs.separate(videoURL: url, time: 500)
        
//        for img in imgs {
//            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
//            print("save img")
//        }
    }
    
}
 // MARK: AVCapturePhotoCaptureDelegate
extension CameraConfiguration: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
        if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            self.photoCaptureCompletionBlock?(image, nil)
        }
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
}
// MARK: AVCaptureFileOutputRecordingDelegate
extension CameraConfiguration: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            self.videoRecordCompletionBlock?(outputFileURL, nil)
        } else {
            self.videoRecordCompletionBlock?(nil, error)
        }
    }
}

extension CameraConfiguration: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}

extension AVCaptureDevice {

    func configureDesiredFrameRate(_ desiredFrameRate: Int) {
        var isFPSSupported = false

        do {
            
            if let videoSupportedFrameRateRanges = activeFormat.videoSupportedFrameRateRanges as? [AVFrameRateRange] {
                for range in videoSupportedFrameRateRanges {
                    if (range.maxFrameRate >= Double(desiredFrameRate) && range.minFrameRate <= Double(desiredFrameRate)) {
                        isFPSSupported = true
                        break
                    }
                }
            }

            if isFPSSupported {
                try lockForConfiguration()
                activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFrameRate))
                activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFrameRate))
                unlockForConfiguration()
            }

        } catch {
            print("lockForConfiguration error: \(error.localizedDescription)")
        }
    }

}


extension CameraConfiguration {
    
    func setupISO(iso: Float = 0, time: Int = 0, wb: Int = 2500, tint: Int = 0, handler: @escaping (Error?)-> Void ) {
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
//            captureSession.sessionPreset = .hd4K3840x2160
            print(rearCamera?.formats.first?.minISO ?? 0)
            print(rearCamera?.formats.first?.maxISO ?? 0)
            
            print("max WB = \(rearCamera?.maxWhiteBalanceGain ?? 0)")
            try rearCamera?.lockForConfiguration()
            rearCamera?.whiteBalanceMode = .locked
            let tempTint: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(wb), tint: Float(tint))
            let gains = rearCamera?.deviceWhiteBalanceGains(for: tempTint)
            rearCamera?.setWhiteBalanceModeLocked(with: gains!, completionHandler: nil)
            rearCamera?.unlockForConfiguration()
            
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            if iso > 0 && time > 0 {
                try rearCamera?.lockForConfiguration()
                rearCamera?.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: Int32(time)), iso: iso, completionHandler: nil)
                rearCamera?.unlockForConfiguration()
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                    self.currentCameraPosition = .rear
                } else {
                    print("error 1")
                    throw CameraControllerError.inputsAreInvalid
                }
            }
        }
        
        DispatchQueue(label: "setup").async {
            do {
                try configureDeviceInputs()
            } catch {
                DispatchQueue.main.async {
                    handler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                handler(nil)
            }
        }
    }
}
