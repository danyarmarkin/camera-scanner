//
//  ConnectionDeviceTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import UIKit

class ConnectionDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var charging: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var storage: UILabel!
    @IBOutlet weak var battery: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String, storage: Int, battery: Int) {
        self.deviceName.text = name
        self.storage.text = "\(storage) Gb"
        self.battery.text = "\(battery)%"
        var b = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {timer in
            self.setCharging(b)
            if b { b = false } else { b = true }
        })
    }
    
    func setCharging(_ state: Bool) {
        if state {
            UIView.animate(withDuration: 0.5, animations: {
                self.charging.bounds = CGRect(x: 0, y: 0, width: 0, height: self.charging.bounds.height)
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.charging.bounds = CGRect(x: 0, y: 0, width: 24, height: self.charging.bounds.height)
            })
        }
    }

}
