//
//  DeleteAllBadSessionsTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 13.11.2021.
//

import UIKit
import simd

class DeleteAllBadSessionsTableViewCell: UITableViewCell {
    
    var videoUrls: [URL] = []
    var delegate: UITableViewController!
    
    func configure(urls: [URL]) {
        videoUrls = urls
    }
    
    func deleteSessions(videoUrls: [URL]) {
        let fileManager = FileManager()
        for i in videoUrls {
            try? fileManager.removeItem(atPath: i.path)
        }
    }

    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm deletion", message: "All data (trash list) will be lost.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) {action in
            self.deleteSessions(videoUrls: self.videoUrls)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
}
