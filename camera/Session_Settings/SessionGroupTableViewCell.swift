//
//  SessionGroupTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 06.07.2021.
//

import UIKit

class SessionGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupName: UILabel!
    
    func configure(name: String, color: UIColor = UIColor.black) {
        groupName.text = name
        groupName.textColor = color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
