//
//  BitRateTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 09.12.2021.
//

import UIKit

class BitRateTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var value: UITextField!
    
    func configure() {
        value.delegate = self
        value.addDoneCancelToolbar()
        self.value.text = "\(CameraData.getData(.bitRate))"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onValue(_ sender: UITextField) {
        CameraData.setData(.bitRate, Int(sender.text!) ?? 128)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

