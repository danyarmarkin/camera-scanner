//
//  ProfileTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 24.11.2021.
//

import UIKit

class ProfileTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var params: [String: Any]!
    var index = 0
    
    var delegate: ConfigurationProfileTableViewController!
    
    func configure(_ params: [String: Any]) {
        nameLabel.delegate = self
        
        self.params = params
        nameLabel.text = "\(params["name"] ?? "Unnamed Profile")"
        
        var d = ""
        for i in ConfigurationProfiles.keys {
            d += i
            d += " "
            d += CameraData.params(ConfigurationProfiles.typeFromKey(i), val: params[i] as! Int)
            d += " "
        }
        descriptionLabel.text = d
    }

    @IBAction func onNameChanged(_ sender: UITextField) {
        params["name"] = sender.text
        delegate.profiles[index]["name"] = sender.text
        ConfigurationProfiles.setProfiles(delegate.profiles)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
