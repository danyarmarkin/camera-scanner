//
//  TintCollectionViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import UIKit

class TintCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var name: UILabel!
    let type = cellType.tint
    var delegate: FastSettingsTableViewCell!
    
    override func setDelegate(_ delegate: UITableViewCell) {
        self.delegate = (delegate as! FastSettingsTableViewCell)
    }
    
    override func configure() {
        setVal(val())
        value.addTarget(self, action: #selector(onValue), for: .editingDidBegin)
        value.addTarget(self, action: #selector(onValueChanged), for: .editingChanged)
        value.addTarget(self, action: #selector(onEditingCompleted), for: .editingDidEnd)
    }
    
    @objc func onValueChanged() {
        let val = Int(value.text!) ?? 0
        delegate.slider.setValue(Float(val), animated: false)
    }
    
    @objc func onEditingCompleted() {
        let val = Int(value.text!) ?? 0
        let t = CameraData.type.tint
        if val < min(){
            CameraData.setData(t, min())
        } else if val > max(){
            CameraData.setData(t, max())
        } else {
            CameraData.setData(t, val)
        }
    }
    
    @objc func onValue() {
        delegate.collectionView(delegate.collectionView, didSelectItemAt: [0, 3])
        if delegate.doubleClick[3] % 2 != 0  {
            delegate.endEditing(true)
        }
    }
    
    override func min() -> Int {
        -45
    }
    
    override func max() -> Int {
        45
    }
    
    override func val() -> Int {
        return CameraData.getData(.tint)
    }
    
    override func setVal(_ val: Int) {
        value.text = "\(val)"
        CameraData.setData(.tint, val)
    }
}
