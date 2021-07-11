//
//  CameraViewController.swift
//  camera
//
//  Created by Данила Ярмаркин on 16.06.2021.
//

import UIKit
import Foundation
import CoreMedia
import Firebase

class CameraViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    let videoRecordingStartedId = "isStartVideo"
    let currentSessionId = "currentSession"
    let mainDeviceId = "mainDevice"
    
    var previousSession = "AAAA"
    
    @IBOutlet weak var ni: UINavigationItem!
    @IBOutlet weak var currentSession: UILabel!
    @IBOutlet weak var cameraButton: CustomButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoDuration: UILabel!
    @IBOutlet weak var isoView: UILabel!
    @IBOutlet weak var shutterView: UILabel!
    @IBOutlet weak var wbView: UILabel!
    @IBOutlet weak var tintView: UILabel!
    @IBOutlet weak var fpsView: UILabel!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var objectNameTextField: UITextField!
    var isTrashButtonActive = false
    
    let localStorage = LocalStorage()
    
    var cameraConfig: CameraConfiguration!
    var cameraConfigs: [CameraConfiguration]! = []
    var index = 0
    let imagePickerController = UIImagePickerController()

    var iso = 32
    var shutter = 5
    var wb = 5000
    var tint = 0
    var fps = 24
    
    var durationTimer = Timer()
    var duration = 0
    
    var devicesAmount = 1
    var deviceIndex = 1
    var objectName = "object"
    
    var videoRecordingStarted: Bool = false {
        didSet{
            if videoRecordingStarted {
                cameraButton.backgroundColor = UIColor.red
            } else {
                cameraButton.backgroundColor = UIColor.gray
            }
        }
    }
    
    fileprivate func registerNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name(rawValue: "App is going background"), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        if videoRecordingStarted {
            videoRecordingStarted = false
            cameraConfig.stopRecording { (error) in
                print(error ?? "Video recording error")
            }
        }
    }
    
    @objc func appCameToForeground() {
        print("app enters foreground")
    }
    
    func camConf(fps: Int) -> CameraConfiguration {
        let cCnfg: CameraConfiguration? = CameraConfiguration()
        cCnfg?.setup (handler: { (error) in
            if error != nil {
                print("error: \(String(describing: error))")
            }
            cCnfg?.rearCamera?.configureDesiredFrameRate(fps)
            cCnfg?.captureSession?.startRunning()
            try? cCnfg?.displayPreview(self.previewImageView)
        })
        cCnfg?.outputType = .video

        return cCnfg!
    }
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        ni.title = "text"
        cameraConfig = camConf(fps: 8)

        cameraButton.tintColor = UIColor.black
        registerNotification()
        
        objectNameTextField.delegate = self
        
        print(LocalStorage.getString(key: LocalStorage.currentSession))
        
        let updateParam = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: {(timer) in
//            self.currentSession.text = LocalStorage.getString(key: LocalStorage.currentSession)

            let iso = LocalStorage.getInt(key: LocalStorage.isoVal)
            let shutter = LocalStorage.getInt(key: LocalStorage.shutterVal)
            let wb = LocalStorage.getInt(key: LocalStorage.wbVal)
            let tint = LocalStorage.getInt(key: LocalStorage.tintVal)
            let fps = LocalStorage.getInt(key: LocalStorage.fpsVal)
            
            if iso == 0 || shutter == 0 || wb == 0 || fps == 0 { return }
            
            if (iso != self.iso || shutter != self.shutter || wb != self.wb || tint != self.tint || fps != self.fps) && !LocalStorage.getBool(key: LocalStorage.sliderOn) {
                self.iso = iso
                self.shutter = shutter
                self.wb = wb
                self.tint = tint
                self.fps = fps
                self.isoView.text = "ISO\n\n\(iso)"
                self.shutterView.text = "Shutter\n\n\(Int(1000/shutter))"
                self.wbView.text = "WB\n\n\(wb)"
                self.tintView.text = "Tint\n\n\(tint)"
                self.fpsView.text = "FPS\n\n\(fps)"
                self.cameraConfig.setupISO(iso: Float(self.iso), time: self.shutter, wb: self.wb, tint: self.tint, handler: {(error) in
                    if error != nil {
                        print("error: \(String(describing: error))")
                    }
                    self.cameraConfig.rearCamera?.configureDesiredFrameRate(self.fps)
                })
            }
        })
        updateParam.tolerance = 0.15
        UIApplication.shared.isIdleTimerDisabled = true
        monitoringData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc fileprivate func showToastForSaved() {
        showToast(message: "Saved!", fontSize: 12.0)
    }
    
    @objc fileprivate func showToastForRecordingStopped() {
        showToast(message: "Recording Stopped", fontSize: 12.0)
    }
    
    @objc fileprivate func showToastForAddToTrashList() {
        showToast(message: "Session \(self.previousSession) added to trash list", fontSize: 12.0)
    }
    
    @objc func video(_ video: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
        }
        print("video")
        print(video)
        
    }
    @IBAction func onobject(_ sender: UITextField) {
        ref.child("objectName").setValue(sender.text)
    }
    
    // MARK: Camera button clicked

    @IBAction func onDidCameraButtonClicked(_ sender: Any) {
        self.ref.child("movePrivousSessionToTrashList").setValue(0)
        if videoRecordingStarted {
            ref.child(videoRecordingStartedId).setValue(0)
        } else if !videoRecordingStarted {
            ref.child(videoRecordingStartedId).setValue(1)
        }
        isTrashButtonActive = false
        trashButton.backgroundColor = .systemGreen
    }
    @IBAction func sendSessionToTrashList(_ sender: Any) {
        if previousSession.suffix(1) == "A" {
            return
        }
        if isTrashButtonActive {
            for i in 1...Int(previousSession.suffix(1))! {
                let session = sessionWithParams(num: i, max: Int(previousSession.suffix(1))!)
                self.ref.child("trashList").child(session).setValue(0)
                isTrashButtonActive = false
                trashButton.backgroundColor = .systemGreen
            }
        } else {
            for i in 1...Int(previousSession.suffix(1))! {
                let session = sessionWithParams(num: i, max: Int(previousSession.suffix(1))!)
                self.ref.child("trashList").child(session).setValue(1)
                isTrashButtonActive = true
                trashButton.backgroundColor = .systemOrange
            }
        }
    }
    
    override func accessibilityElementDidBecomeFocused() {
        super.accessibilityElementDidBecomeFocused()
        print("focused")
    }
    
    // MARK: Monitoring Data

    func monitoringData() {
        ref.child(videoRecordingStartedId).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                
                if val == 0 && self.videoRecordingStarted {
                    self.videoRecordingStarted = false
                    self.durationTimer.invalidate()
                    self.videoDuration.text = "0:00"
                    self.duration = 0
                    self.cameraConfig.stopRecording { (error) in
                        print(error ?? "Video recording error")
                    }
                    print(0)
                } else if val == 1 && !self.videoRecordingStarted {
                    self.durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in
                        self.duration += 1
                        let seconds = self.duration % 60
                        if seconds < 10 {
                            self.videoDuration.text = "\(Int(floor(Double(self.duration / 60)))):0\(seconds)"
                        } else {
                            self.videoDuration.text = "\(Int(floor(Double(self.duration / 60)))):\(seconds)"
                        }
                    })
                    self.durationTimer.tolerance = 0.01
                    self.videoRecordingStarted = true
                    self.cameraConfig.recordVideo { (url, error) in
                        guard let url = url else {
                            print(error ?? "Video recording error")
                            return
                        }
//                        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)), nil)
                        self.previousSession = LocalStorage.getString(key: LocalStorage.currentSession)
                        LocalStorage.appendArray(key: LocalStorage.sessionArray,
                                                 value: [LocalStorage.getString(key: LocalStorage.currentSession),
                                                         url.path])
                        if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
                            let session = LocalStorage.randomSessionId(length: 4)
                            self.ref.child(self.currentSessionId).setValue(session)
                        }
                        self.showToastForSaved()
                    }
                    print(1)
                }
            }
        })
        
        // MARK: Devices & session Control

        ref.child(currentSessionId).observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? String {
                LocalStorage.set(key: LocalStorage.sessionId, val: val)
                self.updateSession()
            }
        })
        
        ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            
            if let val = value as? Int {
                self.deviceIndex = val
            }
            if !self.videoRecordingStarted {
                self.updateSession()
                self.currentSession.tintColor = nil
            } else {
                self.updateSession()
                self.currentSession.tintColor = .systemRed
            }
        })
        
        ref.child("devicesAmount").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            
            if let val = value as? Int {
                self.devicesAmount = val
            }
            if !self.videoRecordingStarted {
                self.updateSession()
                self.currentSession.tintColor = nil
            } else {
                self.updateSession()
                self.currentSession.tintColor = .systemRed
            }
        })
        
        ref.child("objectName").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? String {
                self.objectName = val
                self.updateSession()
            }
        })
        
        // MARK: Date Control
         

        ref.child(mainDeviceId).observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? String {
                if val == LocalStorage.getString(key: LocalStorage.deviceName) {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
                }
            }
        })
        
        ref.child("cameraConf/iso").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.isoVal, val: val)
            }
            
        })
        ref.child("cameraConf/shutter").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.shutterVal, val: val)
            }
            
        })
        ref.child("cameraConf/wb").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.wbVal, val: val)
            }
            
        })
        ref.child("cameraConf/tint").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.tintVal, val: val)
            }
            
        })
        ref.child("cameraConf/fps").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.fpsVal, val: val)
            }
            
        })
        
        ref.child("movePrivousSessionToTrashList").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                if val == 1 {
                    LocalStorage.appendArray(key: LocalStorage.trashList, value: self.previousSession)
                    self.showToastForAddToTrashList()
                }
            }
        })
    }
    
    func updateSession() {
        let val = "_\(LocalStorage.getString(key: LocalStorage.sessionId))_\(deviceIndex)\(devicesAmount)"
        objectNameTextField.text = objectName
        currentSession.text = val
        LocalStorage.set(key: LocalStorage.currentSession, val: objectName + val)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func sessionWithParams(num: Int, max: Int) -> String {
        let val = "\(previousSession.prefix(previousSession.count - 3))_\(num)\(max)"
        return val
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil {
//            self.galleryButton.contentMode = .scaleAspectFit
//            self.galleryButton.setImage( pickedImage, for: .normal)
        }
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print("videoURL:\(String(describing: videoURL))")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}


extension CameraViewController {
    func exportVideo(url: String = "file:///var/mobile/Containers/Data/Application/8AD37CFE-0366-4D43-AED5-7799A4457854/Documents/SRRO.mov") {

        let filePath = url

        let videoLink = NSURL(fileURLWithPath: filePath)

        let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Session", forKey: "subject")

        self.present(activityVC, animated: true, completion: nil)

    }
}


