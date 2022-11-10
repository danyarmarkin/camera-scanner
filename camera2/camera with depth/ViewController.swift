//
//  ViewController.swift
//  camera with depth
//
//  Created by Данила Ярмаркин on 07.11.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
    

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var depthImageView: UIImageView!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    private var captureSession: AVCaptureSession?
    private var videoOutput =  AVCaptureVideoDataOutput()
    private var depthOutput = AVCaptureDepthDataOutput()
    var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    
    var videoFilename = ""
    var depthFilename = ""
    
    var videoAssetWriter: AVAssetWriter?
    var depthAssetWriter: AVAssetWriter?
    
    var videoAssetWriterInput: AVAssetWriterInput?
    var depthAssetWriterInput: AVAssetWriterInput?
    
    var videoAdapter: AVAssetWriterInputPixelBufferAdaptor?
    var depthAdapter: AVAssetWriterInputPixelBufferAdaptor?
    
    var _videoTime: Double = 0
    var _depthTime: Double = 0
    
    
    enum CaptureState {
        case idle, start, capturing, end
    }
    var captureState: CaptureState = .idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        
//        if #available(iOS 15.4, *) {
//            captureDevice = AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back)
//        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
//            input.ports(for: .depthData, sourceDeviceType: .builtInTripleCamera, sourceDevicePosition: .back)
            
            captureSession = AVCaptureSession()
            captureSession?.beginConfiguration()
            captureSession?.addInput(input)
            captureSession?.commitConfiguration()
            captureSession?.sessionPreset = .photo
            
            captureSession?.addOutput(videoOutput)
            
            
            depthOutput.isFilteringEnabled = true
            captureSession?.addOutput(depthOutput)
            
            outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoOutput, depthOutput])
            outputSynchronizer?.setDelegate(self, queue: DispatchQueue(label: "com.kanistra.sinchr_video"))
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            self.videoImageView.layer.addSublayer(videoPreviewLayer)
            captureSession?.startRunning()
            
//            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
//                print(captureDevice?.lensPosition)
//                print(captureDevice?.lensAperture)
//            }
            
            
        } catch {
            print(error)
            return
        }
    }
    
    let videoSetting: [String : Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc,
        AVVideoWidthKey: 4000,
        AVVideoHeightKey: 3000,
        AVVideoCompressionPropertiesKey: [
            AVVideoMaxKeyFrameIntervalKey: 1,
        ]
    ]
    let depthSetting: [String : Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc,
        AVVideoWidthKey: 320,
        AVVideoHeightKey: 240,
    ]
    
    @IBAction func onButton(_ sender: Any) {
        switch captureState {
        case .idle:
            captureState = .start
            button.tintColor = .systemRed
        case .capturing:
            captureState = .end
            button.tintColor = .lightGray
        case .end, .start:
            break
        }
    }
    

}

extension ViewController: AVCaptureDataOutputSynchronizerDelegate {
    
    
    
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

        let rowData = CVPixelBufferGetBaseAddress(rawDepthPixelBuffer)! + (height / 2) * CVPixelBufferGetBytesPerRow(rawDepthPixelBuffer)
        let d = rowData.assumingMemoryBound(to: Float32.self)[width / 2]
//        print(d)
        
        for yMap in 0 ..< height {
            let rowData = CVPixelBufferGetBaseAddress(rawDepthPixelBuffer)! + yMap * CVPixelBufferGetBytesPerRow(rawDepthPixelBuffer)
            let data = UnsafeMutableBufferPointer<Float32>(start: rowData.assumingMemoryBound(to: Float32.self), count: width)
            
            for index in 0 ..< width {
                if data[index] > d + 0.2{
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
            let filename = UUID().uuidString
            videoFilename = filename + "_video"
            depthFilename = filename + "_depth"
            
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(videoFilename).mov")
            let depthPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(depthFilename).mov")
            
            videoAssetWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            depthAssetWriter = try! AVAssetWriter(outputURL: depthPath, fileType: .mov)
            
            videoAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSetting)
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
            guard videoAssetWriterInput?.isReadyForMoreMediaData == true, videoAssetWriter?.status != .failed else {
                print("video writer failed")
                return
            }
            videoAssetWriterInput?.markAsFinished()
            videoAssetWriter?.finishWriting(completionHandler: { [weak self] in
                self?.captureState = .idle
                self?.videoAssetWriter = nil
                self?.videoAssetWriterInput = nil
            })
            
            guard depthAssetWriterInput?.isReadyForMoreMediaData == true, depthAssetWriter?.status != .failed else {
                print("depth writer failed")
                return
            }
            depthAssetWriterInput?.markAsFinished()
            depthAssetWriter?.finishWriting(completionHandler: { [weak self] in
                self?.captureState = .idle
                self?.depthAssetWriter = nil
                self?.depthAssetWriterInput = nil
            })
            
            
        default:
            break
        }
    }
    
    
}
