//
//  MakeDeviceCentralTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import UIKit

class MakeDeviceCentralTableViewCell: UITableViewCell {
    
    var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ onAction: @escaping () -> Void) {
        action = onAction
    }

    @IBAction func onCentral(_ sender: Any) {
        (action ?? {return})()
    }
}
