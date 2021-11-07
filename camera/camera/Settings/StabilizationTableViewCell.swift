//
//  StabilizationTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 29.10.2021.
//

import UIKit

class StabilizationTableViewCell: UITableViewCell {

    @IBOutlet weak var stabizationLabel: UILabel!
    @IBOutlet weak var stabilizationSwitch: UISwitch!
    
    func configure() {
        stabilizationSwitch.setOn(LocalStorage.getBool(key: LocalStorage.isStabilization), animated: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitch(_ sender: UISwitch) {
        LocalStorage.set(key: LocalStorage.isStabilization, val: sender.isOn)
    }
}
