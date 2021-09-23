//
//  DeviceStatusCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 23.09.2021.
//

import UIKit

class DeviceStatusCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var batteryBar: UIProgressView!
    @IBOutlet weak var storageBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String, battery: Int) {
        deviceName.text = name
        batteryBar.tintColor = .systemGreen
        storageBar.tintColor = .systemBlue
        batteryBar.setProgress(Float(battery) / 100, animated: false)
        if battery <= 20 {
            batteryBar.tintColor = .systemOrange
        }
        if battery <= 10 {
            batteryBar.tintColor = .systemRed
        }
    }

}
