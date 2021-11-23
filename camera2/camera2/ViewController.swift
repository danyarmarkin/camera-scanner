//
//  ViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "stabization")
    }


}

