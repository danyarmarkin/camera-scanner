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
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureVideoOutput: AVCaptureMovieFileOutput?
    var captureDevice: AVCaptureDevice?
    var imageView: UIImageView!
    @objc let cameraSettings = CameraSettings()
    var observation: NSKeyValueObservation?
    
    var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    var videoSettings: [String : Any] {
        var settings: [String : Any] = [:]
        settings[AVVideoCodecKey] = AVVideoCodecType.hevc
        var bitRate = CameraData.getData(.bitRate)
        if bitRate <= 0 {bitRate = 128}
        settings[AVVideoCompressionPropertiesKey] = [AVVideoAverageBitRateKey: bitRate * 1024 * 1024]
        return settings
    }
    
    init(imageView: UIImageView, delegate: UIViewController) {
        self.imageView = imageView
        
        captureDevice = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            captureVideoOutput = AVCaptureMovieFileOutput()
            captureSession?.addOutput(captureVideoOutput!)
            captureSession?.sessionPreset = .hd4K3840x2160
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = delegate.view.layer.bounds
            self.imageView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            _ = CameraSettingsObserver(capDev: captureDevice!, settings: cameraSettings, output: captureVideoOutput!)
            
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
    
    
    func getUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
