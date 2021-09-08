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
    
    var hostController: UITableViewController!
    
    var ref: DatabaseReference!
    
    func configure(text: String, switchVal: Bool = true, previewImage: UIImage = UIImage.init(systemName: "paperplane.fill")!, duration: Int = 90, host: UITableViewController) {
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
        hostController = host
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
        let session: String! = sessionName.text
        let s = session.split(separator: "_")
        let max = Int(s[s.count - 3].suffix(1))!
        if !sender.isOn {
            for i in 1...max {
                ref.child("trashList").child("\(session.prefix(session.count - 16))\(i)\(max)_\(s[s.count - 2])_\(s[s.count - 1])").setValue(1)
            }
        } else {
            for i in 1...max {
                ref.child("trashList").child("\(session.prefix(session.count - 16))\(i)\(max)_\(s[s.count - 2])_\(s[s.count - 1])").setValue(0)
            }
        }
    }
    @IBAction func export(_ sender: Any) {
        let url = sessionName.text
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("\(url!).mov")
        let filePath = fileUrl.path
        let videoLink = NSURL(fileURLWithPath: filePath)
        let activityVC = UIActivityViewController(activityItems: [videoLink], applicationActivities: nil)
        activityVC.setValue("Session", forKey: "subject")
        hostController.present(activityVC, animated: true, completion: nil)
//        self.inputAccessoryViewController
    }
    

}
