//
//  StabilizationModeTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 30.11.2021.
//

import UIKit

class StabilizationModeTableViewController: UITableViewController {
    
    var cells:[StabilizationModeTableViewCell] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stabilization_mode_cell") as! StabilizationModeTableViewCell
            switch i {
            case 0:
                cell.configure(.off)
            case 1:
                cell.configure(.standard)
            case 2:
                cell.configure(.auto)
            case 3:
                cell.configure(.cinematic)
            case 4:
                cell.configure(.cinematicExtended)
            default:
                cell.configure(.off)
            }
            cells.append(cell)
            
            let selected = StabilizationConfig.getStablizationMode()
            for cell in cells {
                if cell.mode == selected {
                    cell.setSelected(true)
                } else {
                    cell.setSelected(false)
                }
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath[1]]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath[1]
        for i in 0...cells.count - 1 {
            if i == index {
                cells[i].setSelected(true)
            } else {
                cells[i].setSelected(false)
            }
        }
        StabilizationConfig.setStablilizationMode(cells[index].mode)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Stabilization Mode"
    }

}
