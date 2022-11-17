//
//  Camera.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import Foundation
import AVFoundation
import UIKit

class Camera: NSObject{
    
    let defaults = UserDefaults.standard
    
    var captureSession: AVCaptureSession?
    private var videoOutput =  AVCaptureVideoDataOutput()
    private var depthOutput = AVCaptureDepthDataOutput()
    var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureVideoOutput: AVCaptureMovieFileOutput?
    var captureDevice: AVCaptureDevice?
    var videoImageView: UIImageView!
    var depthImageView: UIImageView!
    @objc let cameraSettings = CameraSettings()
    var observation: NSKeyValueObservation?
    
    var videoAssetWriter: AVAssetWriter?
    var depthAssetWriter: AVAssetWriter?
    
    var videoAssetWriterInput: AVAssetWriterInput?
    var depthAssetWriterInput: AVAssetWriterInput?
    
    var videoAdapter: AVAssetWriterInputPixelBufferAdaptor?
    var depthAdapter: AVAssetWriterInputPixelBufferAdaptor?
    
    var _videoTime: Double = 0
    var _depthTime: Double = 0
    
    var videoFilename = ""
    var depthFilename = ""
    
    var videoDidEnd = false
    var depthDidEnd = false
    
    enum CaptureState {
        case idle, start, capturing, end
    }
    var captureState: CaptureState = .idle
    
    var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    var videoSettings: [String : Any] {
        var settings: [String : Any] = [:]
        settings[AVVideoCodecKey] = AVVideoCodecType.hevc
        var bitRate = CameraData.getData(.bitRate)
        if bitRate <= 0 {bitRate = 128}
        settings[AVVideoWidthKey] = 4032
        settings[AVVideoHeightKey] = 3024
        settings[AVVideoCompressionPropertiesKey] = [AVVideoAverageBitRateKey: bitRate * 1024 * 1024]
        return settings
    }
    
    let depthSetting: [String : Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc,
        AVVideoWidthKey: 320,
        AVVideoHeightKey: 240,
    ]
    
    override init() {
        print("init")
    }
    
    func configure(videoImageView: UIImageView, depthImageView: UIImageView, delegate: UIViewController) {
        self.videoImageView = videoImageView
        self.depthImageView = depthImageView
        
        if #available(iOS 15.4, *) {
            captureDevice = AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back)
        } else {
            captureDevice = nil
        }
        if captureDevice == nil {
            captureDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
        }
        if captureDevice == nil {
            captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.beginConfiguration()
            captureSession?.addInput(input)
            captureSession?.commitConfiguration()
            captureSession?.sessionPreset = .photo
            
            depthOutput.isFilteringEnabled = true
            captureSession?.addOutput(depthOutput)
            captureSession?.addOutput(videoOutput)
            
            outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoOutput, depthOutput])
            outputSynchronizer?.setDelegate(self, queue: DispatchQueue(label: "com.kanistra.sinchr_video"))
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = delegate.view.layer.bounds
            self.videoImageView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            _ = CameraSettingsObserver(capDev: captureDevice!, settings: cameraSettings)
            
            cameraSettings.monitoringData()
            
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    
    func recordVideo(session: Session, complition: @escaping (URL?, Error?) -> Void) {
        let captureConnection = (captureVideoOutput?.connection(with: .video))!
        captureVideoOutput?.setOutputSettings(videoSettings, for: captureConnection)
        let path = getUrl().path + "/\(session.getFileName())"
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        captureVideoOutput?.startRecording(to: URL(fileURLWithPath: path), recordingDelegate: self)
        videoRecordCompletionBlock = complition
    }
    
    func startRecording(session: Session, complition: @escaping (URL?, Error?) -> Void) {
        videoFilename = session.getFileName()
        depthFilename = videoFilename + "_depth"
        videoRecordCompletionBlock = complition
        captureState = .start
    }
    
    func stopRecording() {
        captureState = .end
    }
    
    
    func getUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    var minDepth = Float32(0)
    var frameIndex = 0
}

extension Camera: AVCaptureDataOutputSynchronizerDelegate {
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        guard
            let syncedDepthData: AVCaptureSynchronizedDepthData = synchronizedDataCollection.synchronizedData(for: depthOutput) as? AVCaptureSynchronizedDepthData,
            let syncedVideoData: AVCaptureSynchronizedSampleBufferData = synchronizedDataCollection.synchronizedData(for: videoOutput) as? AVCaptureSynchronizedSampleBufferData
        else {
            // only work on synced pairs
            return
        }
        
        if syncedDepthData.depthDataWasDropped || syncedVideoData.sampleBufferWasDropped {
            return
        }
        
        let depthData = syncedDepthData.depthData
        var convertedDepth: AVDepthData
        let depthDataType = kCVPixelFormatType_DepthFloat32
        if depthData.depthDataType != depthDataType {
            convertedDepth = depthData.converting(toDepthDataType: depthDataType)
        } else {
            convertedDepth = depthData
        }
        
        let rawDepthPixelBuffer = convertedDepth.depthDataMap
        let height = CVPixelBufferGetHeight(rawDepthPixelBuffer)
        let width = CVPixelBufferGetWidth(rawDepthPixelBuffer)

        CVPixelBufferLockBaseAddress(rawDepthPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        if frameIndex == 0 {
            DispatchQueue.global().sync {
                minDepth = Float32(1000)
                for yMap in 0 ..< height {
                    let rowData = CVPixelBufferGetBaseAddress(rawDepthPixelBuffer)! + yMap * CVPixelBufferGetBytesPerRow(rawDepthPixelBuffer)
                    for index in 0 ..< width {
                        if minDepth > rowData.assumingMemoryBound(to: Float32.self)[index / 2] {
                            minDepth = rowData.assumingMemoryBound(to: Float32.self)[index / 2]
                        }
                    }
                }
            }
        }
        
        frameIndex += 1
        frameIndex %= 3
    
        for yMap in 0 ..< height {
            let rowData = CVPixelBufferGetBaseAddress(rawDepthPixelBuffer)! + yMap * CVPixelBufferGetBytesPerRow(rawDepthPixelBuffer)
            let data = UnsafeMutableBufferPointer<Float32>(start: rowData.assumingMemoryBound(to: Float32.self), count: width)
            
            for index in 0 ..< width {
                if data[index] > minDepth + 0.8 {
                    data[index] = 0
                } else {
                    data[index] = 1
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(rawDepthPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let depthMap = CIImage(cvPixelBuffer: rawDepthPixelBuffer)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(depthMap, from: depthMap.extent)!
        
        let depthPixelBuffer = cgImage.pixelBuffer(width: width, height: height, orientation: .up)
    
        let image: UIImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        DispatchQueue.main.sync {
            depthImageView.image = image
        }
        
        guard
            let videoPixelBuffer = CMSampleBufferGetImageBuffer(syncedVideoData.sampleBuffer)
        else {
            return
        }
        
        let videoTimestamp = syncedVideoData.timestamp.seconds
        let depthTimestamp = syncedDepthData.timestamp.seconds
        
        
        switch captureState {
        case .start:
            if videoFilename == "" || depthFilename == "" {
                let filename = UUID().uuidString
                videoFilename = filename
                depthFilename = filename + "_depth"
            }
            
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(videoFilename).mov")
            let depthPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(depthFilename).mov")
            
            videoAssetWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            depthAssetWriter = try! AVAssetWriter(outputURL: depthPath, fileType: .mov)
            
            videoAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            depthAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: depthSetting)
            
            videoAssetWriterInput?.mediaTimeScale = CMTimeScale(bitPattern: 600)
            depthAssetWriterInput?.mediaTimeScale = CMTimeScale(bitPattern: 600)
            
            videoAssetWriterInput?.expectsMediaDataInRealTime = true
            depthAssetWriterInput?.expectsMediaDataInRealTime = true
            
            videoAssetWriterInput?.transform = CGAffineTransform(rotationAngle: .pi / 2)
            depthAssetWriterInput?.transform = CGAffineTransform(rotationAngle: .pi / 2)
            
            videoAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoAssetWriterInput!)
            depthAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: depthAssetWriterInput!)
            
            videoAssetWriter?.add(videoAssetWriterInput!)
            depthAssetWriter?.add(depthAssetWriterInput!)
            
            videoAssetWriter?.startWriting()
            videoAssetWriter?.startSession(atSourceTime: .zero)
            depthAssetWriter?.startWriting()
            depthAssetWriter?.startSession(atSourceTime: .zero)
            
            
            captureState = .capturing
            
            _videoTime = videoTimestamp
            _depthTime = depthTimestamp
            
            
        case .capturing:
            if (videoAssetWriterInput?.isReadyForMoreMediaData) == true {
                let time = CMTime(seconds: videoTimestamp - _videoTime, preferredTimescale: CMTimeScale(bitPattern: 600))
                let r = videoAdapter?.append(videoPixelBuffer, withPresentationTime: time)
                if !(r ?? false){
                    print("video wrong")
                }
            }

            if (depthAssetWriterInput?.isReadyForMoreMediaData) == true {
                let time = CMTime(seconds: depthTimestamp - _depthTime, preferredTimescale: CMTimeScale(bitPattern: 600))
                let r = depthAdapter?.append(depthPixelBuffer!, withPresentationTime: time)
                if !(r ?? false){
                    print("depth wrong")
                }
            } else {
                print("depth asset writer input failed")
            }
            break
            
        case .end:
            if videoAssetWriterInput?.isReadyForMoreMediaData == true && videoAssetWriter?.status != .failed {
                videoAssetWriterInput?.markAsFinished()
                videoAssetWriter?.finishWriting(completionHandler: { [weak self] in
                    self?.videoDidEnd = true
                    if self?.depthDidEnd ?? false {
                        self?.videoDidEnd = false
                        self?.depthDidEnd = false
                        self?.captureState = .idle
                        DispatchQueue.main.sync {
                            self?.videoRecordCompletionBlock!(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self?.videoFilename ?? "video").mov"), nil)
                        }
                    }
                    self?.videoAssetWriter = nil
                    self?.videoAssetWriterInput = nil
                })
            }
            
            if depthAssetWriterInput?.isReadyForMoreMediaData == true && depthAssetWriter?.status != .failed {
                depthAssetWriterInput?.markAsFinished()
                depthAssetWriter?.finishWriting(completionHandler: { [weak self] in
                    self?.depthDidEnd = true
                    if self?.videoDidEnd ?? false {
                        self?.videoDidEnd = false
                        self?.depthDidEnd = false
                        self?.captureState = .idle
                        DispatchQueue.main.sync {
                            self?.videoRecordCompletionBlock!(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self?.videoFilename ?? "video").mov"), nil)
                        }
                    }
                    self?.depthAssetWriter = nil
                    self?.depthAssetWriterInput = nil
                })
            }
            
        default:
            break
        }
        
    }
}

extension Camera: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            self.videoRecordCompletionBlock?(outputFileURL, nil)
        } else {
            self.videoRecordCompletionBlock?(nil, error)
        }
    }
}
