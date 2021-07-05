//
//  SessionTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 19.06.2021.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var isTrash: UISwitch!
    
    
    func configure(text: String, switchVal: Bool = true) {
        sessionName.text = text
        isTrash.isOn = switchVal
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onTrash(_ sender: UISwitch) {
        if !sender.isOn {
            LocalStorage.appendArray(key: LocalStorage.trashList, value: sessionName.text ?? "AAAA")
            print("added session \(sessionName.text ?? "AAAA") to trash list")
        } else {
            LocalStorage.removeArrayStringElement(key: LocalStorage.trashList, value: sessionName.text ?? "AAAA")
            print("revoved session \(sessionName.text ?? "AAAA") from trash list")
        }
    }
    

}
