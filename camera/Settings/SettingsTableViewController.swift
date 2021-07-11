//
//  SettingsTableViewController.swift
//  camera
//
//  Created by Данила Ярмаркин on 25.06.2021.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"
    let cameraConfId = "cameraConf"
    
    var configSettings = [["max": 700,
                           "min": 34,
                           "val": 50],["max": 500,
                                       "min": 5,
                                       "val": 200],["max": 8000,
                                                   "min": 2000,
                                                   "val": 3500],["max": 50,
                                                               "min": -50,
                                                               "val": 0],["max": 60,
                                                                           "min": 4,
                                                                           "val": 24],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        monitoringData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 5 { return 1 }
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var numberCell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as! NumberTableViewCell
        var sliderCell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderTableViewCell
        var isMainDeviceCell = tableView.dequeueReusableCell(withIdentifier: "main_device_cell", for: indexPath) as! MainDeviceTableViewCell
        
        if indexPath == [5, 0] {
            isMainDeviceCell.configure()
            return isMainDeviceCell
        }
        
        switch indexPath[1] {
        case 0:
            numberCell = configNumberCell(cell: numberCell, ind: indexPath[0])
            return numberCell
            
        default:
            sliderCell = configSliderCell(cell: sliderCell, ind: indexPath[0])
            return sliderCell
        }
    }
    
    func configNumberCell(cell: NumberTableViewCell, ind: Int)  -> NumberTableViewCell {
        switch ind {
        case 0:
            cell.configure(type: UITableViewCell.cellType.iso, val: configSettings[ind]["val"]!)
            break
        
        case 1:
            cell.configure(type: UITableViewCell.cellType.shutter, val: configSettings[ind]["val"]!)
            break
            
        case 2:
            cell.configure(type: UITableViewCell.cellType.wb, val: configSettings[ind]["val"]!)
            break
            
        case 3:
            cell.configure(type: UITableViewCell.cellType.tint, val: configSettings[ind]["val"]!)
            break
            
        case 4:
            cell.configure(type: UITableViewCell.cellType.fps, val: configSettings[ind]["val"]!)
            break
            
        default:
            break
        }
        
        return cell
    }
    
    func configSliderCell(cell: SliderTableViewCell, ind: Int) -> SliderTableViewCell {
        switch ind {
        case 0:
            cell.configure(type: UITableViewCell.cellType.iso,
                           max: configSettings[ind]["max"]!,
                           min: configSettings[ind]["min"]!,
                           val: Float(configSettings[ind]["val"]!))
            break
        
        case 1:
            cell.configure(type: UITableViewCell.cellType.shutter,
                           max: configSettings[ind]["max"]!,
                           min: configSettings[ind]["min"]!,
                           val: Float(configSettings[ind]["val"]!))
            break
            
        case 2:
            cell.configure(type: UITableViewCell.cellType.wb,
                           max: configSettings[ind]["max"]!,
                           min: configSettings[ind]["min"]!,
                           val: Float(configSettings[ind]["val"]!))
            break
            
        case 3:
            cell.configure(type: UITableViewCell.cellType.tint,
                           max: configSettings[ind]["max"]!,
                           min: configSettings[ind]["min"]!,
                           val: Float(configSettings[ind]["val"]!))
            break
            
        case 4:
            cell.configure(type: UITableViewCell.cellType.fps,
                           max: configSettings[ind]["max"]!,
                           min: configSettings[ind]["min"]!,
                           val: Float(configSettings[ind]["val"]!))
            break
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "ISO"
        case 1:
            return "Shutter"
        case 2:
            return "White Balance"
        case 3:
            return "Tint"
        case 4:
            return "FPS"
        case 5:
            return "Device"
        default:
            return "no name section"
        }
    }
    
    func monitoringData() {
        ref.child("cameraConf/iso").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.isoVal, val: val)
                self.updateSettings()
                if LocalStorage.getBool(key: LocalStorage.sliderOn) {
                    self.tableView.reloadRows(at: [[0,0]], with: UITableView.RowAnimation.none)
                } else {
                    self.tableView.reloadRows(at: [[0,0],[0,1]], with: UITableView.RowAnimation.none)
                }
            }
            
        })
        ref.child("cameraConf/shutter").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.shutterVal, val: val)
                self.updateSettings()
                if LocalStorage.getBool(key: LocalStorage.sliderOn) {
                    self.tableView.reloadRows(at: [[1,0]], with: UITableView.RowAnimation.none)
                } else {
                    self.tableView.reloadRows(at: [[1,0],[1,1]], with: UITableView.RowAnimation.none)
                }
            }
            
        })
        ref.child("cameraConf/wb").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.wbVal, val: val)
                self.updateSettings()
                if LocalStorage.getBool(key: LocalStorage.sliderOn) {
                    self.tableView.reloadRows(at: [[2,0]], with: UITableView.RowAnimation.none)
                } else {
                    self.tableView.reloadRows(at: [[2,0],[2,1]], with: UITableView.RowAnimation.none)
                }
            }
            
        })
        ref.child("cameraConf/tint").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.tintVal, val: val)
                self.updateSettings()
                if LocalStorage.getBool(key: LocalStorage.sliderOn) {
                    self.tableView.reloadRows(at: [[3,0]], with: UITableView.RowAnimation.none)
                } else {
                    self.tableView.reloadRows(at: [[3,0],[3,1]], with: UITableView.RowAnimation.none)
                }
            }
            
        })
        ref.child("cameraConf/fps").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.fpsVal, val: val)
                self.updateSettings()
                if LocalStorage.getBool(key: LocalStorage.sliderOn) {
                    self.tableView.reloadRows(at: [[4,0]], with: UITableView.RowAnimation.none)
                } else {
                    self.tableView.reloadRows(at: [[4,0],[4,1]], with: UITableView.RowAnimation.none)
                }
            }
            
        })
    }
    
    func updateSettings() {
        configSettings[0]["val"] = LocalStorage.getInt(key: LocalStorage.isoVal)
        if LocalStorage.getInt(key: LocalStorage.shutterVal) == 0 {
            LocalStorage.set(key: LocalStorage.shutterVal, val: 5)
        }
        configSettings[1]["val"] = LocalStorage.getInt(key: LocalStorage.shutterVal)
        configSettings[2]["val"] = LocalStorage.getInt(key: LocalStorage.wbVal)
        configSettings[3]["val"] = LocalStorage.getInt(key: LocalStorage.tintVal)
        configSettings[4]["val"] = LocalStorage.getInt(key: LocalStorage.fpsVal)
//        print(configSettings)
//        self.tableView.reloadData()
    }
}



extension UITableViewCell {
    enum cellType {
        case iso
        case shutter
        case wb
        case tint
        case fps
    }
    
    static let cellName = [cellType.iso : "ISO",
                           cellType.shutter: "Shutter",
                           cellType.wb : "White Balance (K)",
                           cellType.tint : "Tint",
                           cellType.fps : "FPS"]
}
