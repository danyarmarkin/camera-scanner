//
//  FocusTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 26.11.2021.
//

import UIKit

class FocusTableViewCell: UITableViewCell {

    @IBOutlet weak var preview: UILabel!
    
    func configure() {
        let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            let type = FocusConfig.getFocusRangeRestriction()
            switch type {
            case .none:
                self.preview.text = "None"
            case .near:
                self.preview.text = "Near"
            case .far:
                self.preview.text = "Far"
            @unknown default:
                fatalError()
            }
        }
        t.tolerance = 0.7
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
