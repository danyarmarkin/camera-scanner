//
//  CameraTypeTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 25.11.2022.
//

import UIKit
import AVFoundation

class CameraTypeTableViewController: UITableViewController {
    
    var cells = [CameraTypeTableViewCell]()
    var availableTypes = [AVCaptureDevice.DeviceType]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if (AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil) {
            availableTypes.append(.builtInWideAngleCamera)
            let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
            cell.configure(type: .builtInWideAngleCamera)
            cells.append(cell)
        }
        if (AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil) {
            availableTypes.append(.builtInUltraWideCamera)
            let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
            cell.configure(type: .builtInUltraWideCamera)
            cells.append(cell)
        }
        if (AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil) {
            availableTypes.append(.builtInTelephotoCamera)
            let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
            cell.configure(type: .builtInTelephotoCamera)
            cells.append(cell)
        }
        if (AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) != nil) {
            availableTypes.append(.builtInDualCamera)
            let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
            cell.configure(type: .builtInDualCamera)
            cells.append(cell)
        }
        if (AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) != nil) {
            availableTypes.append(.builtInDualWideCamera)
            let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
            cell.configure(type: .builtInDualWideCamera)
            cells.append(cell)
        }
        if #available(iOS 15.4, *) {
            if (AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back) != nil) {
                availableTypes.append(.builtInLiDARDepthCamera)
                let cell = tableView.dequeueReusableCell(withIdentifier: "camera_type_cell") as! CameraTypeTableViewCell
                cell.configure(type: .builtInLiDARDepthCamera)
                cells.append(cell)
            }
        }
        
        print("camera type")
        
        let type = CameraTypeConfig.getCameraType()
        
        for cell in cells {
            if cell.type == type {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = cells[indexPath.row].type
        for i in 0..<cells.count {
            if i == indexPath.row {
                cells[i].accessoryType = .checkmark
            } else {
                cells[i].accessoryType = .none
            }
        }
        CameraTypeConfig.setCameraType(type)
    }

}

