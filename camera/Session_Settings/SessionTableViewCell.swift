//
//  SessionTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 19.06.2021.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionName: UILabel!
    
    
    func configure(text: String) {
        sessionName.text = text
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
