//
//  ViewController.swift
//  camera
//
//  Created by Данила Ярмаркин on 12.06.2021.
//

import UIKit
import MobileCoreServices
import CoreLocation
import AVFoundation

class ViewController: UIViewController,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate,
        CLLocationManagerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }

}


