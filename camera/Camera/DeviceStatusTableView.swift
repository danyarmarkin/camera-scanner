//
//  DeviceStatusTableView.swift
//  camera
//
//  Created by Данила Ярмаркин on 23.09.2021.
//

import UIKit

class DeviceStatusTableView: UITableView {
    
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        let cell = dequeueReusableCell(withIdentifier: "device_cell") as! DeviceStatusCell
        cell.configure(name: "device #\(indexPath[1])", battery: 0)
        return cell
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        3
    }
    
    func configure() {
        self.rowHeight = 18
    }
    
}
