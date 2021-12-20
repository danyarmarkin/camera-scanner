//
//  SerialNullTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 19.12.2021.
//

import UIKit

class SerialNullTableViewCell: UITableViewCell {
    
    var delegate: UITableViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onClick(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm action", message: "Value of serial counter will be 0", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Set 0", style: .destructive) {action in
            Server.serialNull()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
}
