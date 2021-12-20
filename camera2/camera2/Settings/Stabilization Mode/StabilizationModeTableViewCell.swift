//
//  StabilizationModeTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 30.11.2021.
//

import UIKit
import AVFoundation

class StabilizationModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    var isCheck = false
    var mode: AVCaptureVideoStabilizationMode!
    
    func configure(_ mode: AVCaptureVideoStabilizationMode){
        self.mode = mode
        switch mode {
        case .off:
            name.text = "Off"
        case .standard:
            name.text = "Standart"
        case .cinematic:
            name.text = "Cinematic"
        case .cinematicExtended:
            name.text = "Cinematic Extended"
        case .auto:
            name.text = "Auto"
        @unknown default:
            fatalError()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSelected(_ status: Bool) {
        if !status {
            isCheck = false
            checkImage.isHidden = true
        } else {
            isCheck = true
            checkImage.isHidden = false
        }
    }

}
