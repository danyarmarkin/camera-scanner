//
//  ConfigurationProfileTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 23.11.2021.
//

import UIKit

class ConfigurationProfileTableViewController: UITableViewController {
    
    var profiles:[[String: Any]] = ConfigurationProfiles.getProfiles()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {timer in
            if self.profiles.count != ConfigurationProfiles.getProfiles().count {
                self.updateData()
            }
        }
        updateTimer.tolerance = 1

         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateData() {
        profiles = ConfigurationProfiles.getProfiles()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    @IBAction func addProfile(_ sender: Any) {
        var profile: [String: Any] = [:]
        for key in ConfigurationProfiles.keys {
            profile[key] = CameraData.getData(ConfigurationProfiles.typeFromKey(key))
        }
        ConfigurationProfiles.addProfile(profile)
        updateData()
    }
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return profiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profile_cell", for: indexPath) as! ProfileTableViewCell

        cell.configure(profiles[indexPath[1]])
        cell.delegate = self
        cell.index = indexPath[1]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = profiles[indexPath[1]]
        let alert = UIAlertController(title: "Confirm profile", message: "Do you realy want to set the \(profile["name"] ?? "Unnamed Profile") profile?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
            ConfigurationProfiles.setProfileData(profile)
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ConfigurationProfiles.removeProfile(indexPath[1])
            updateData()
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
