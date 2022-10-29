//
//  ViewController.swift
//  animation
//
//  Created by Данила Ярмаркин on 05.10.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { timer in
            UIView.animate(withDuration: 0.5, animations: {
//                self.imageView.frame = CGRect(x: 0, y: 0, width: Int.random(in: 1..<100), height: Int.random(in: 1..<100))
                self.imageView.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
            })
        })
    }


}

