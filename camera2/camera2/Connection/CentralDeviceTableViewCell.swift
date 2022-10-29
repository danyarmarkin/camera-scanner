//
//  CentralDeviceTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import UIKit

class CentralDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String) {
        if UIDevice.current.name == name {
            deviceName.text = "\(name) (this)"
        } else {
            deviceName.text = name
        }
    }

}
