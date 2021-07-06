//
//  SessionTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 19.06.2021.
//

import UIKit
import Firebase

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var isTrash: UISwitch!
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var fps: UILabel!
    
    var ref: DatabaseReference!
    
    func configure(text: String, switchVal: Bool = true, previewImage: UIImage = UIImage.init(systemName: "paperplane.fill")!, duration: Int = 90) {
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        sessionName.text = text
        isTrash.isOn = switchVal
        preview.image = previewImage
        let seconds = duration % 60
        if seconds < 10 {
            length.text = "\(Int(floor(Double(duration / 60)))):0\(seconds)"
        } else {
            length.text = "\(Int(floor(Double(duration / 60)))):\(seconds)"
        }
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
//            LocalStorage.appendArray(key: LocalStorage.trashList, value: sessionName.text ?? "AAAA")
            ref.child("trashList").child(sessionName.text ?? "AAAA").setValue(1)
            print("added session \(sessionName.text ?? "AAAA") to trash list")
        } else {
//            LocalStorage.removeArrayStringElement(key: LocalStorage.trashList, value: sessionName.text ?? "AAAA")
            ref.child("trashList").child(sessionName.text ?? "AAAA").setValue(0)
            print("revoved session \(sessionName.text ?? "AAAA") from trash list")
        }
    }
    

}
