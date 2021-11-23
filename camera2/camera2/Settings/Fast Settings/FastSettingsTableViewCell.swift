//
//  FastSettingsTableViewCell.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import UIKit

class FastSettingsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var slider: UISlider!
    
    var delegate: UITableViewController!
    var cells: [UICollectionViewCell] = []
    var doubleClick = [0, 0, 0, 0, 0]
    var selectedIndex = 0
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        cells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "iso_cell", for: [0, 0]) as! IsoCollectionViewCell)
        cells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "shutter_cell", for: [0, 1]) as! ShutterCollectionViewCell)
        cells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "wb_cell", for: [0, 2]) as! WBCollectionViewCell)
        cells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "tint_cell", for: [0, 3]) as! TintCollectionViewCell)
        cells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "fps_cell", for: [0, 4]) as! FPSCollectionViewCell)
        collectionView(collectionView, didSelectItemAt: [0, 1])
        for cell in cells {
            cell.configure()
            cell.setDelegate(self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cells[indexPath[1]]
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0...4 {
            if i == indexPath[1] {
                doubleClick[i] += 1
            } else {
                doubleClick[i] = 0
            }
        }
        for cell in cells {
            cell.backgroundColor = .none
            cell.setEnabled(false)
        }
        selectedIndex = indexPath[1]
        cells[selectedIndex].setEnabled(true)
        cells[selectedIndex].backgroundColor = .lightGray
        slider.minimumValue = Float(cells[selectedIndex].min())
        slider.maximumValue = Float(cells[selectedIndex].max())
        slider.setValue(Float(cells[selectedIndex].val()), animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.size.width / CGFloat(collectionView.numberOfItems(inSection: 0) + 1), height: collectionView.bounds.size.height)
    }
    
    @IBAction func onSlider(_ sender: UISlider) {
        cells[selectedIndex].setVal(Int(sender.value))
    }
    
    func dismissKeyboard() {
        for i in cells {
            i.endEditing(true)
        }
    }
    
}

