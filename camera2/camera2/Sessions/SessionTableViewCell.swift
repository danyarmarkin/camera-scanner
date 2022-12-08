//
//  SessionTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 13.11.2021.
//

import UIKit
import AVFoundation
import AVKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var fps: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var turns: UILabel!
    
    var videoURL = URL(fileURLWithPath: "")
    var delegate: UITableViewController!
    
    let defaultPreviewImage = UIImage.init(systemName: "photo")
    
    func configure(url: URL) {
        videoURL = url
        reload()
    }
    
    func export(videoUrl: URL) {
        var shareFiles: [NSURL] = []
        shareFiles.append(NSURL(fileURLWithPath: videoUrl.path))
        let activityVC = UIActivityViewController(activityItems: shareFiles, applicationActivities: nil)
        activityVC.setValue("Session", forKey: "subject")
        delegate.present(activityVC, animated: true, completion: nil)
    }
    
    func reload() {
        let pathComponets = videoURL.path.split(separator: "/")
        previewImageView.image = previewImage(fileUrl:videoURL)
        sessionName.text = "\(pathComponets[pathComponets.count - 1])"
        let videoDuration = videoDuration(fileUrl: videoURL)
        if videoDuration % 60 < 10 {
            time.text = "\(videoDuration / 60):0\(videoDuration % 60)"
        } else {
            time.text = "\(videoDuration / 60):\(videoDuration % 60)"
        }
        fps.text = "\(videoFPS(fileUrl: videoURL)) FPS"
        
        if previewImageView.image == defaultPreviewImage {
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {timer in
                if self.previewImage(fileUrl: self.videoURL) != self.defaultPreviewImage {
                    timer.invalidate()
                    self.reload()
                }
            }
            timer.tolerance = 0.5
        }
    }
    
    @IBAction func onExport(_ sender: Any) {
        export(videoUrl: videoURL)
    }
    
    @IBAction func onTrash(_ sender: UISwitch) {
    }
}


extension SessionTableViewCell {
    func previewImage(fileUrl: URL) -> UIImage{
        let asset = AVAsset(url: fileUrl)
        let generator = AVAssetImageGenerator.init(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime.zero
        generator.requestedTimeToleranceAfter = CMTime.zero
        do {
            let cgImage = try generator.copyCGImage(at: CMTimeMake(value: Int64(1), timescale: 10), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image
        } catch {
            return defaultPreviewImage!
        }
    }
    
    func videoDuration(fileUrl: URL) -> Int{
        let asset = AVAsset(url: fileUrl)
        let durationInSeconds = asset.duration.seconds
        return Int(durationInSeconds)
    }
    
    func videoFPS(fileUrl: URL) -> Int {
        let asset = AVAsset(url: fileUrl)
        let track = asset.tracks(withMediaType: .video)
        return Int(round(track.first?.nominalFrameRate ?? 24))
    }
}
