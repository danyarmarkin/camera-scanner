//
//  FPSCollectionViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import UIKit

class FPSCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UITextField!
    let type = cellType.fps
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
        let t = CameraData.type.fps
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
        delegate.collectionView(delegate.collectionView, didSelectItemAt: [0, 4])
        if delegate.doubleClick[4] % 2 != 0  {
            delegate.endEditing(true)
        }
    }
    
    override func min() -> Int {
        4
    }
    
    override func max() -> Int {
        60
    }
    
    override func val() -> Int {
        return CameraData.getData(.fps)
    }
    
    override func setVal(_ val: Int) {
        value.text = "\(val)"
        CameraData.setData(.fps, val)
    }
}
