//
//  StabilizationTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 30.11.2021.
//

import UIKit

class StabilizationTableViewCell: UITableViewCell {

    @IBOutlet weak var preview: UILabel!
    
    func configure() {
        let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            let mode = StabilizationConfig.getStablizationMode()
            switch mode {
            case .off:
                self.preview.text = "Off"
            case .standard:
                self.preview.text = "Standart"
            case .cinematic:
                self.preview.text = "Cinematic"
            case .cinematicExtended:
                self.preview.text = "Cinematic Extended"
            case .auto:
                self.preview.text = "Auto"
            @unknown default:
                fatalError()
            }
        }
        t.tolerance = 0.7
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
