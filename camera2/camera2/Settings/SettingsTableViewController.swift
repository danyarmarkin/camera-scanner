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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {return 2}
        return 8
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "fast_settings_cell", for: indexPath) as! FastSettingsTableViewCell
            cell.configure()
            cell.delegate = self
            return cell
        case [1, 0]:
            return tableView.dequeueReusableCell(withIdentifier: "configuration_profiles_cell", for: indexPath)
        case [1, 1]:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "focus_cell", for: indexPath) as! FocusTableViewCell
            cell.configure()
            return cell
        case [1, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stabilization_cell", for: indexPath) as! StabilizationTableViewCell
            cell.configure()
            return cell
        case [1, 3]:
            return tableView.dequeueReusableCell(withIdentifier: "server_cell", for: indexPath)
        case [1, 4]:
            return tableView.dequeueReusableCell(withIdentifier: "naming_cell", for: indexPath)
        case [1, 5]:
            return tableView.dequeueReusableCell(withIdentifier: "syncronization_cell", for: indexPath)
        case [1, 6]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "bit_rate_cell", for: indexPath) as! BitRateTableViewCell
            cell.configure()
            return cell
        case [1, 7]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "serial_null_cell", for: indexPath) as! SerialNullTableViewCell
            cell.delegate = self
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "void_settings_cell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1, 3] {
//            performSegue(withIdentifier: "sync_view_controller", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[0] == 1 {return 50}
        return 120
    }
}


extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
