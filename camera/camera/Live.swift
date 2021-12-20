//
//  Live.swift
//  camera
//
//  Created by Данила Ярмаркин on 02.07.2021.
//

import Foundation
import UIKit
import Firebase

class Live {
    func registerLive() {
        NotificationCenter.default.addObserver(self, selector: #selector(s), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func s() {
        print("ok")
    }
}
