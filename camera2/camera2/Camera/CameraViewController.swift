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
    @IBOutlet weak var depthImageView: UIImageView!
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
        camera = Camera()
        camera.configure(videoImageView: imageView, depthImageView: depthImageView, delegate: self)
        cameraSettings.monitoringData()
        
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.configure()
        deviceTableView.reloadData()
        
        listenVolumeButton()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            self.settingsLabel.text = "ISO \(self.cameraSettings.iso) SH \((self.cameraSettings.shutter as! CMTime).timescale) WB \(self.cameraSettings.wb) FPS \(self.cameraSettings.fps)"
        }
        timer.tolerance = 0.1
        
        
        // MARK: Monitor session params
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStrartNotification(_:)), name: Notification.Name(SessionConfig.isStartKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionNameNotification(_:)), name: Notification.Name(SessionConfig.sessionNameKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionObjectNotification(_:)), name: Notification.Name(SessionConfig.sessionObjectKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStrartNotification(_:)), name: Notification.Name(SessionConfig.isStartKeyC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionNameNotification(_:)), name: Notification.Name(SessionConfig.sessionNameKeyC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionObjectNotification(_:)), name: Notification.Name(SessionConfig.sessionObjectKeyC), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceIndex(_:)), name: NSNotification.Name(DevicesData.deviceIndexKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDevicesAmount(_:)), name: NSNotification.Name(DevicesData.devicesAmountKey), object: nil)
        
        
        SessionConfig.setData(forCamera: .sessionName, SessionConfig.getSessionName())
        SessionConfig.setData(forCamera: .sessionObject, SessionConfig.getSessionObject())
        
        DevicesData.setDeviceIndex(DevicesData.getDeviceIndex())
        DevicesData.setDevicesAmount(DevicesData.getDevicesAmount())
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onDeviceIndex(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        let v = info["value"] as! Int
        self.session.deviceIndex = v
        self.sessionLabel.text = self.session.getShortName()
    }
    
    @objc func onDevicesAmount(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        let v = info["value"] as! Int
        self.session.deviceAmount = v
        self.sessionLabel.text = self.session.getShortName()
    }
    
    @objc func onStrartNotification(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        let v = Int(info["value"] as! String)
        
        if (isStartSession && v == 1) || (!isStartSession && v == 0) {
            return
        } else {
            self.isStartSession = v == 0
            self.updateSession()
        }
    }
    
    @objc func onSessionNameNotification(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        let v = info["value"] as! String
        self.session.sessionName = v
        self.sessionLabel.text = self.session.getShortName()
    }
    
    @objc func onSessionObjectNotification(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        let v = info["value"] as! String
        self.sessionTextField.text = v
    }
    
    
    @objc func didTapView(){
      self.view.endEditing(true)
    }
    
    // MARK: Update session
    func updateSession() {
        print("update session")
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
            camera.startRecording(session: session) {(url, error) in
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
            camera.stopRecording()
            if durationTimer != nil{
                self.durationTimer.invalidate()
                self.timerLabel.text = "0:00"
            }
        }
    }
    
    
    // MARK: On Video
    
    func onVideoStateDidUpdate() {
        if isStartSession {
            SessionConfig.setData(.isStart, "0")
            SessionConfig.updateSession()
        } else {
            SessionConfig.setData(.isStart, "1")
        }
    }
    
    @IBAction func onVideo(_ sender: Any) {
        onVideoStateDidUpdate()
    }

    @IBAction func onTrash(_ sender: Any) {
    }
    
    @IBAction func refreshSession(_ sender: UIButton) {
        SessionConfig.updateSession(updateIndex: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onSessionObjectName(_ sender: UITextField) {
        // TODO: create notification for change session name
        SessionConfig.setData(.sessionObject, sender.text ?? "object")
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
              onVideoStateDidUpdate()
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
        deviceTableView.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device_cell") as! DeviceStatusCell
        let device = deviceTableView.devices[indexPath.row]
        cell.configure(name: device.name,
                       battery: device.battery,
                       storage: device.storage,
                       totalStorage: device.totalStorage)
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
