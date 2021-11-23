//
//  SettingsTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.11.2021.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.tableView(self.tableView, cellForRowAt: [0, 0]).addGestureRecognizer(tapRecognizer)

    }
    
    @objc func didTapView(){
      self.view.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "fast_settings_cell", for: indexPath) as! FastSettingsTableViewCell
            cell.configure()
            cell.delegate = self
            return cell
        case [0, 2]:
            return tableView.dequeueReusableCell(withIdentifier: "configuration_profiles_cell", for: indexPath)
        case [0, 3]:
            return tableView.dequeueReusableCell(withIdentifier: "focus_cell", for: indexPath)
        case [0, 4]:
            return tableView.dequeueReusableCell(withIdentifier: "stabilization_cell", for: indexPath)
        case [0, 5]:
            return tableView.dequeueReusableCell(withIdentifier: "sincronization_cell", for: indexPath)
        case [0, 6]:
            return tableView.dequeueReusableCell(withIdentifier: "naming_cell", for: indexPath)
        default:
            return tableView.dequeueReusableCell(withIdentifier: "void_settings_cell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[1] >= 2 {return 50}
        return 120
    }

}
