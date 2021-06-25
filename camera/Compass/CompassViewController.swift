//
// Created by Данила Ярмаркин on 13.06.2021.
//

import Foundation
import UIKit
import CoreLocation
import CoreMotion

class CompassViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var compassBar: UIProgressView!
    @IBOutlet weak var compassValue: UILabel!

    var delta: Float = 0
    var preVal: Float = 0
    var currentVal: Float = 0
    var isStart = true
    var isRev = false

    var motion = CMMotionManager()
    var timer: Timer!

    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()

        motion.startGyroUpdates()
        motion.startAccelerometerUpdates()
//        startAccelerometers()
//        LocalStorage.set(key: LocalStorage.currentSession, val: "HDOV")
        print("view did load")

        LocalStorage.set(key: LocalStorage.currentSession, val: LocalStorage.randomSessionId(length: 4))
        LocalStorage.set(key: LocalStorage.sliderOn, val: false)

        UIApplication.shared.isIdleTimerDisabled = true
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

}
