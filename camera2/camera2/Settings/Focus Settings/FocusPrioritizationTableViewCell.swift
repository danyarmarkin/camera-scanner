//
//  FocusPrioritizationTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 26.11.2021.
//

import UIKit
import AVFoundation

class FocusPrioritizationTableViewCell: UITableViewCell {
    
    var type: AVCaptureDevice.AutoFocusRangeRestriction = .none
    var isCheck = false
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    
    func configure(_ type: AVCaptureDevice.AutoFocusRangeRestriction) {
        self.type = type
        switch type {
        case .none:
            name.text = "None"
        case .near:
            name.text = "Near"
        case .far:
            name.text = "Far"
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

