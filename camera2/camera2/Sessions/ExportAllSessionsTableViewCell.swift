//
//  ExportAllSessionsTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 13.11.2021.
//

import UIKit

class ExportAllSessionsTableViewCell: UITableViewCell {
    
    var videoUrls: [URL] = []
    var delegate: UITableViewController!
    @IBOutlet weak var exportButton: UIButton!
    
    func configure(urls: [URL]) {
        videoUrls = urls
    }
    
    func share() {
        var shareFiles: [NSURL] = []
        for i in videoUrls {
            shareFiles.append(NSURL(fileURLWithPath: i.path))
        }
        let activityVC = UIActivityViewController(activityItems: shareFiles, applicationActivities: nil)
        activityVC.setValue("Session", forKey: "subject")
        delegate.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func onExport(_ sender: Any) {
        share()
    }
}
