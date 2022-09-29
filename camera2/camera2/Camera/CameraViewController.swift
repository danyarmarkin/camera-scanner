//
//  CameraViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import UIKit
import MetricKit
import Firebase
import MediaPlayer

class CameraViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var buttonView: UIStackView!
    @IBOutlet weak var refreshSessionButton: UIButton!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var sessionTextField: UITextField!
    @IBOutlet weak var sessionView: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var deviceTableView: DeviceStatusTableView!
    
    var camera: Camera!
    let cameraSettings = CameraSettings()
    var session = Session()
    var isStartSession = false
    
    var durationTimer: Timer!
    var duration = 0
    
    let ref = Database.database(url: Server.firebasePath).reference()
    
    let audioSession = AVAudioSession.sharedInstance()
    let volumeView = MPVolumeView()
    
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        let metricManager = MXMetricManager.shared
        metricManager.add(self)
        
        sessionTextField.delegate = self
        camera = Camera(imageView: imageView, delegate: self)
        cameraSettings.monitoringData()
        
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.configure()
        deviceTableView.reloadData()
        
        listenVolumeButton()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            self.settingsLabel.text = "ISO \(self.cameraSettings.iso) SH \((self.cameraSettings.shutter as! CMTime).timescale) WB \(self.cameraSettings.wb) FPS \(self.cameraSettings.fps)"
            if self.session.deviceIndex == 0 {
                Server.registerDevice()
            }
        }
        timer.tolerance = 0.1
        
        
        // MARK: Monitor session params
        ref.child("sessionLife").child("isStart").observe(.value){snapshot in
            let val = snapshot.value
            if let v = val as? Int {
                if ![0, 1].contains(v) {return}
                self.isStartSession = v == 0
                self.updateSession()
            }
        }
        
        ref.child("sessionName").observe(.value){snapshot in
            let val = snapshot.value
            if let v = val as? String {
                self.session.sessionName = v
                self.sessionLabel.text = self.session.getShortName()
            }
        }
        
        ref.child("object").observe(.value) {snapshot in
            let val = snapshot.value
            if let v = val as? String {
                self.sessionTextField.text = v
            }
        }
        
        ref.child("devices").child(Server.getDeviceName()).observe(.value) {snapshot in
            let val = snapshot.value
            if let v = val as? Int {
                self.session.deviceIndex = v
                self.sessionLabel.text = self.session.getShortName()
            }
        }
        
        ref.child("devicesAmount").observe(.value) {snapshot in
            let val = snapshot.value
            if let v = val as? Int {
                self.session.deviceAmount = v
                self.sessionLabel.text = self.session.getShortName()
            }
        }
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
      self.view.endEditing(true)
    }
    
    // MARK: Update session
    func updateSession() {
        if !isStartSession {
            isStartSession = true
            session.objectName = sessionTextField.text ?? "unnamed"
            durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {timer in
                self.duration += 1
                let seconds = self.duration % 60
                if seconds < 10 {
                    self.timerLabel.text = "\(Int(floor(Double(self.duration / 60)))):0\(seconds)"
                } else {
                    self.timerLabel.text = "\(Int(floor(Double(self.duration / 60)))):\(seconds)"
                }
            }
            camera.recordVideo(session: session) {(url, error) in
                guard url != nil else {
                    print(error ?? "error")
                    return
                }
                let seconds = self.duration % 60
                if seconds < 10 {
                    self.showToast(message: "Video Saved \(self.duration / 60):0\(seconds)", fontSize: 20)
                } else {
                    self.showToast(message: "Video Saved \(self.duration / 60):\(seconds)", fontSize: 20)
                }
                self.duration = 0
                print("video saved")
            }
            videoButton.backgroundColor = .systemRed
        } else {
            isStartSession = false
            videoButton.backgroundColor = .lightGray
            camera.captureVideoOutput?.stopRecording()
            if durationTimer != nil{
                self.durationTimer.invalidate()
                self.timerLabel.text = "0:00"
            }
        }
    }
    
    
    // MARK: On Video
    @IBAction func onVideo(_ sender: Any) {
        if isStartSession {
            ref.child("sessionLife").child("isStart").setValue(0)
        } else {
            ref.child("sessionLife").child("isStart").setValue(1)
        }
    }

    @IBAction func onTrash(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onSessionObjectName(_ sender: UITextField) {
        ref.child("object").setValue(sender.text)
    }
    
    
    // MARK: Volume button listener
    func listenVolumeButton() {
        for i in 1...5 {
            do {
                try audioSession.setActive(true)
                break
            } catch {
                print("audio session error")
                if i == 5 {
                    showToast(message: "Can not bind volume button", fontSize: 15)
                }
            }
        }
       audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }

    var volumeTapped = false
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if keyPath == "outputVolume" {
          if !volumeTapped {
              if isStartSession {
                  ref.child("sessionLife").child("isStart").setValue(0)
              } else {
                  ref.child("sessionLife").child("isStart").setValue(1)
              }
          }
          if let view = volumeView.subviews.first as? UISlider{
              if !volumeTapped {
                  view.value = 0.5
                  volumeTapped = true
              }
          }
          _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
              self.volumeTapped = false
          })
        }
    }
    
    
    // MARK: Devices State Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deviceTableView.activeDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device_cell") as! DeviceStatusCell
        let name = deviceTableView.activeDevices[indexPath[1]]
        let device = deviceTableView.activeDevices[indexPath[1]].split(separator: "-")[0]
        cell.configure(name: String(device), battery: deviceTableView.batteryData[name] ?? 50, storage: deviceTableView.storageData[name] ?? 1024, totalStorage: deviceTableView.totalStorageData[name] ?? 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        false
    }
}


// MARK: SHOW Toast
extension UIViewController {
    
    func showToast(message : String, fontSize: CGFloat) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 200, y: self.view.frame.size.height-self.view.frame.size.height/3.7, width: 400, height: 35))
        toastLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.black
        toastLabel.font = UIFont.systemFont(ofSize: fontSize)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 3, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension CameraViewController: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
      guard let firstPayload = payloads.first else { return }
      print(firstPayload.dictionaryRepresentation())
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
      guard let firstPayload = payloads.first else { return }
      print(firstPayload.dictionaryRepresentation())
    }
}
