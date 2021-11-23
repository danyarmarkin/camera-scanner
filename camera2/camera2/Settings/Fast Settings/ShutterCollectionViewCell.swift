//
//  ShutterCollectionViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import UIKit

class ShutterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UITextField!
    let type = cellType.shutter
    var delegate: FastSettingsTableViewCell!
    
    override func setDelegate(_ delegate: UITableViewCell) {
        self.delegate = (delegate as! FastSettingsTableViewCell)
    }
    
    override func configure() {
        setVal(val())
        value.addTarget(self, action: #selector(onValue), for: .editingDidBegin)
        value.addTarget(self, action: #selector(onValueChanged), for: .editingChanged)
    }
    
    @objc func onValueChanged() {
        let val = Int(value.text!) ?? 0
        let t = CameraData.type.shutter
        if val < min(){
            CameraData.setData(t, min())
        } else if val > max(){
            CameraData.setData(t, max())
        } else {
            CameraData.setData(t, val)
        }
        delegate.slider.setValue(Float(val), animated: false)
    }
    
    @objc func onValue() {
        delegate.collectionView(delegate.collectionView, didSelectItemAt: [0, 1])
        if delegate.doubleClick[1] % 2 != 0 {
            delegate.endEditing(true)
        }
    }
    
    override func min() -> Int {
        1
    }
    
    override func max() -> Int {
        1000
    }
    
    override func val() -> Int {
        return CameraData.getData(.shutter)
    }
    
    override func setVal(_ val: Int) {
        value.text = "\(val)"
        CameraData.setData(.shutter, val)
    }
}
