//
//  ConnectionTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import UIKit

class ConnectionTableViewController: UITableViewController {
    
    var devices: [ConnectionDevice] = []
    
    var bluetoothCentral: BluetoothCentral!
    var bluetoothPeripheral: BluetoothPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothPeripheral = BluetoothPeripheral()
        bluetoothPeripheral.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDevices(_:)), name: NSNotification.Name(DevicesData.devicesDataKey), object: nil)
    }
    
    @objc func updateDevices(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        devices = info["value"] as! [ConnectionDevice]
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 { return 2 }
        return devices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == [0, 0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "central_device_cell", for: indexPath) as! CentralDeviceTableViewCell
            for device in devices {
                if device.isCentral {
                    cell.configure(name: device.name)
                }
            }
            return cell
        }
        
        if indexPath == [0, 1] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "make_device_central_cell", for: indexPath) as! MakeDeviceCentralTableViewCell
            cell.configure {
                self.bluetoothPeripheral = nil
                self.bluetoothCentral = BluetoothCentral()
                self.bluetoothCentral.configure()
                self.bluetoothCentral.onDevicesChanged = {
                    var d = [ConnectionDevice]()
                    
                    let cd = ConnectionDevice()
                    cd.name = UIDevice.current.name
                    cd.battery = Server.battery()
                    cd.storage = Server.storage()
                    cd.totalStorage = Server.totalStorage()
                    d.append(cd)
                    
                    for pd in self.bluetoothCentral.peripheralDevides {
                        var cd = ConnectionDevice()
                        cd.name = pd.peripheral?.name ?? "unnamed"
                        for device in self.devices {
                            if device.name == cd.name {
                                cd = device
                            }
                        }
                        d.append(cd)
                    }
                    
                    self.devices = d
                    self.bluetoothCentral.updateDevicesState(for: self.devices)
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                        Server.updateParam()
                    }
                }
                self.bluetoothCentral.onDeviceDataChanged = {name, key, value in
                    if self.devices.count == 0 { return }
                    for i in 0...self.devices.count - 1 {
                        let device = self.devices[i]
                        if device.name == name {
                            switch key {
                            case DevicesData.batteryKey:
                                device.battery = value
                            case DevicesData.storageKey:
                                device.storage = value
                            case DevicesData.totalStorageKey:
                                device.totalStorage = value
                            default:
                                break
                            }
                            self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
                            break
                        }
                    }
                    DevicesData.setData(self.devices)
                    self.bluetoothCentral.updateDevicesState(for: self.devices)
                }
            }
            return cell
        }
        
        if indexPath[0] == 1 {
            let device = devices[indexPath[1]]
            let cell = tableView.dequeueReusableCell(withIdentifier: "connection_device_cell", for: indexPath) as! ConnectionDeviceTableViewCell
            cell.configure(name: device.name, storage: device.storage, battery: device.battery)
            return cell
        }

        return UITableViewCell()
    }
}
