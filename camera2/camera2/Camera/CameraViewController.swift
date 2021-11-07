//
//  CameraViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import UIKit

class CameraViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        camera = Camera(imageView: imageView, delegate: self)
    }
    
    @IBAction func onVideo(_ sender: Any) {
        if !isStartSession {
            isStartSession = true
            session.objectName = "testObject"
            session.sessionName = "001ADFF"
            camera.recordVideo(session: session) {(url, error) in
                guard url != nil else {
                    print(error ?? "error")
                    return
                }
                print("video saved")
            }
            videoButton.backgroundColor = .systemRed
        } else {
            videoButton.backgroundColor = .lightGray
            camera.captureVideoOutput?.stopRecording()
        }
    }

    @IBAction func onTrash(_ sender: Any) {
    }
}
