//
//  VideoSeparator.swift
//  camera
//
//  Created by Данила Ярмаркин on 17.06.2021.
//

import Foundation
import UIKit
import AVFoundation

class VideoSeparator {
    var url: URL!
//    func `init`(URL: URL, interval: Float) {
//        self.url = URL
//
//        var img: UIImage!
//        img = generateThumnail(url: url, fromTime: Float64(0.1))
//        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
//        print("saved 1 img")
//    }
    
    func separate (videoURL: URL, time: Int) {
        print (videoURL)     //used for debugging
        let asset = AVAsset(url: videoURL)
        let durationInSeconds = asset.duration.seconds
        let generator = AVAssetImageGenerator.init(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime.zero
        generator.requestedTimeToleranceAfter = CMTime.zero
        var i = 0
        while i < Int(durationInSeconds) * 1000 {
            let cgImage = try! generator.copyCGImage(at: CMTimeMake(value: Int64(i), timescale: 1000), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            if (cgImage != nil) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            i += time
        }
    }
    
    func generateThumnail(url : URL, fromTime:Float64) -> UIImage? {
        let asset :AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero;
        let time : CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 600)
        if let img = try? assetImgGenerate.copyCGImage(at:time, actualTime: nil) {
            return UIImage(cgImage: img)
        } else {
            return nil
        }
    }

    
}
