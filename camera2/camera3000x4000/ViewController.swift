//
//  ViewController.swift
//  camera3000x4000
//
//  Created by Данила Ярмаркин on 31.08.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureDepthDataOutputDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var depthImageView: UIImageView!
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var depthOtput: AVCaptureDepthDataOutput?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var adapter: AVAssetWriterInputPixelBufferAdaptor?
    var filename = ""
    private var _time: Double = 0
    
    
    let videoSetting: [String : Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc,
        AVVideoWidthKey: 4032,
        AVVideoHeightKey: 3024,
        AVVideoCompressionPropertiesKey: [
            AVVideoMaxKeyFrameIntervalKey: 1,
            AVVideoAverageBitRateKey: 128 * 1024 * 1024
        ]
    ]
    
    var isStart = false;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession?.beginConfiguration()
            captureSession?.addInput(input)
            captureSession?.commitConfiguration()
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.kanistra.video"))
            captureSession?.addOutput(videoOutput!)
            
            depthOtput = AVCaptureDepthDataOutput()
            depthOtput?.isFilteringEnabled = true
            depthOtput?.setDelegate(self, callbackQueue: DispatchQueue(label: "com.kanistra.depth"))
            captureSession?.addOutput(depthOtput!)
            
            captureSession?.sessionPreset = .photo
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            self.imageView.layer.addSublayer(videoPreviewLayer)
//            imageView.transform = imageView.transform.rotated(by: .pi / 2)
            captureSession?.startRunning()
            
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    enum CaptureState {
        case idle, start, capturing, end
    }
    var captureState: CaptureState = .idle

    @IBAction func onTouch(_ sender: Any) {
        switch captureState {
        case .idle:
            captureState = .start
        case .capturing:
            captureState = .end
        case .end, .start:
            break
        }
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        var convertedDepth: AVDepthData
        let depthDataType = kCVPixelFormatType_DepthFloat32
        if depthData.depthDataType != depthDataType {
            convertedDepth = depthData.converting(toDepthDataType: depthDataType)
        } else {
            convertedDepth = depthData
        }
        
        let depthMap = CIImage(depthData: convertedDepth)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(depthMap!, from: depthMap!.extent)!
        let image: UIImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        DispatchQueue.main.sync {
            depthImageView.image = image
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch captureState {
        case .start:
            filename = UUID().uuidString
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
            assetWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSetting)
            assetWriterInput?.mediaTimeScale = CMTimeScale(bitPattern: 600)
            assetWriterInput?.expectsMediaDataInRealTime = true
            assetWriterInput?.transform = CGAffineTransform(rotationAngle: .pi / 2)
            adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!)
            assetWriter?.add(assetWriterInput!)
            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: .zero)
            captureState = .capturing
            _time = timestamp
        case .capturing:
            if (assetWriterInput?.isReadyForMoreMediaData) == true {
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(bitPattern: 600))
                adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
            }
            break
            
        case .end:
            guard assetWriterInput?.isReadyForMoreMediaData == true, assetWriter?.status != .failed else {break}
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
            assetWriterInput?.markAsFinished()
            assetWriter?.finishWriting(completionHandler: { [weak self] in
                self?.captureState = .idle
                self?.assetWriter = nil
                self?.assetWriterInput = nil
                DispatchQueue.main.async {
                    let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self?.present(activity, animated: true, completion: nil)
                }
            })
            
            
        default:
            break
        }
    }

}





