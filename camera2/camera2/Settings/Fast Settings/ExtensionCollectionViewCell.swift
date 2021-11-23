//
//  ExtensionCollectionViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import Foundation
import UIKit
import AVFoundation
extension UICollectionViewCell {
    enum cellType {
        case iso
        case shutter
        case wb
        case tint
        case fps
    }
    @objc func min() -> Int {
        return 0
    }
    @objc func max() -> Int {100}
    @objc func val() -> Int {50}
    @objc func setVal(_ val: Int) {}
    @objc func configure() {}
    @objc func setEnabled(_ state: Bool) {}
    @objc func setDelegate(_ delegate: UITableViewCell) {}
}
