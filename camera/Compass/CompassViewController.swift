//
// Created by Данила Ярмаркин on 13.06.2021.
//

import Foundation
import UIKit
import CoreLocation
import CoreMotion
import Firebase
import AVFoundation

class CompassViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var compassBar: UIProgressView!
    @IBOutlet weak var compassValue: UILabel!

    var delta: Float = 0
    var preVal: Float = 0
    var currentVal: Float = 0
    var isStart = true
    var isRev = false
    var ref: DatabaseReference!

    var motion = CMMotionManager()
    var timer: Timer!

    var locationManager: CLLocationManager!
    
    let devices = DeviceControl()
    
    var outputVolumeObserve: NSKeyValueObservation?
    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        LocalStorage.set(key: LocalStorage.deviceName, val: UIDevice.current.name + "-" + UIDevice.current.model)
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(1)
        devices.configure(ref: ref)
        devices.monitorDevices()
        registerLive()
        motion.startGyroUpdates()
        motion.startAccelerometerUpdates()
        LocalStorage.set(key: LocalStorage.currentSession, val: LocalStorage.randomSessionId(length: 4))
        LocalStorage.set(key: LocalStorage.sliderOn, val: false)
        LocalStorage.set(key: LocalStorage.trashList, val: [])
        
        listenVolumeButton()

        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func listenVolumeButton() {
       do {
        try audioSession.setActive(true)
       } catch {
        print("some error")
       }
       audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if keyPath == "outputVolume" {
        print("Hello")
      }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let m = Float(newHeading.magneticHeading)
        delta = m - preVal
        preVal = m

        let accelX = Float(motion.accelerometerData?.acceleration.x ?? 0)
        let accelY = Float(motion.accelerometerData?.acceleration.y ?? 1)
        let deltaPhi: Float = atan(accelX / abs(accelY)) * 57.299

        if isStart {
            isStart = false
            return
        }

        if 220 > abs(delta) && abs(delta) > 140 {
            if isRev {
                isRev = false
            } else {
                isRev = true
            }
            return
        }

        if isRev {
            if currentVal >= 180 {
                currentVal = m + 180
            } else {
                currentVal = m - 180
            }
            currentVal -= delta
        } else {
            currentVal = m
        }
        currentVal -= deltaPhi
        currentVal -= floor(currentVal / 360) * 360
        
        compassValue.text = String(currentVal)
        compassBar.progress = currentVal / 360

//        print(motion.accelerometerData?.acceleration.x)
//        print(motion.accelerometerData?.acceleration.y)
//        print(motion.accelerometerData?.acceleration.z)
//        print("---")
    }
    func registerLive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterFocus),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didFinishLaunchingNotification,
                                               object: nil)
    }
    
    @objc func enterBackground() {
        devices.unregisterDevice()
    }
    
    @objc func enterFocus() {
        listenVolumeButton()
        devices.registerDevice()
    }

}
