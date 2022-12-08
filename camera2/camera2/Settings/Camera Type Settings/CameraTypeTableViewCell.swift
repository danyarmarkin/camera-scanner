//
//  CameraTypeTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 25.11.2022.
//

import UIKit
import AVFoundation

class CameraTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    var type: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(type: AVCaptureDevice.DeviceType) {
        self.type = type
        
        if #available(iOS 15.4, *) {
            switch type {
            case .builtInWideAngleCamera:
                label.text = "Wide Camera"
            case .builtInUltraWideCamera:
                label.text = "Ultra Wide Camera"
            case .builtInTelephotoCamera:
                label.text = "Telephoto Camera"
            case .builtInDualCamera:
                label.text = "Dual Camera"
            case .builtInDualWideCamera:
                label.text = "Dual Wide Camera"
            case .builtInLiDARDepthCamera:
                label.text = "LiDAR Camera"
            default:
                label.text = "Wide Camera"
            }
        }
    }

}
