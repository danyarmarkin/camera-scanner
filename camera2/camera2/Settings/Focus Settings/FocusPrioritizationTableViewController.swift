//
//  FocusPrioritizationTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 26.11.2021.
//

import UIKit

class FocusPrioritizationTableViewController: UITableViewController {
    
    var cells: [FocusPrioritizationTableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "focus_range_restriction_cell") as! FocusPrioritizationTableViewCell
            
            if i == 0 {
                cell.configure(.none)
            } else if i == 1 {
                cell.configure(.near)
            } else if i == 2 {
                cell.configure(.far)
            }
            cells.append(cell)
        }
        
        let selected = FocusConfig.getFocusRangeRestriction()
        for cell in cells {
            if cell.type == selected {
                cell.setSelected(true)
            } else {
                cell.setSelected(false)
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
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
        FocusConfig.setFocusRangeRestriction(cells[index].type)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath[1]
        return cells[index]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Auto Focus Range Restriction"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 { return "If you expect to focus primarily on near or far objects, you can use the autoFocusRangeRestriction property to provide a hint to the focusing system. This approach makes autofocus faster, more power efficient, and less error prone. A restriction prioritizes focusing at distances in the specified range, but does not prevent focusing elsewhere if the device finds no focus point within that range." }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        160
    }
    
}
