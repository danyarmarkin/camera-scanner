//
//  CameraViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import UIKit
import Firebase
import MediaPlayer

class CameraViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var buttonView: UIStackView!
    @IBOutlet weak var refreshSessionButton: UIButton!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var sessionTextField: UITextField!
    @IBOutlet weak var sessionView: UIStackView!
    
    var camera: Camera!
    var session = Session()
    var isStartSession = false
    let ref = Database.database(url: Server.firebasePath).reference()
    
    let audioSession = AVAudioSession.sharedInstance()
    let volumeView = MPVolumeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenVolumeButton()
        sessionTextField.delegate = self
        camera = Camera(imageView: imageView, delegate: self)
        
        ref.child("sessionLife").child("isStart").observe(.value){snapshot in
            let val = snapshot.value
            if let v = val as? Int {
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
    
    
    func updateSession() {
        if !isStartSession {
            isStartSession = true
            session.objectName = sessionTextField.text ?? "unnamed"
            camera.recordVideo(session: session) {(url, error) in
                guard url != nil else {
                    print(error ?? "error")
                    return
                }
                print("video saved")
            }
            videoButton.backgroundColor = .systemRed
        } else {
            isStartSession = false
            videoButton.backgroundColor = .lightGray
            camera.captureVideoOutput?.stopRecording()
        }
    }
    
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
    
    
    func listenVolumeButton() {
       do {
        try audioSession.setActive(true)
       } catch {
        print("some error")
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
}
