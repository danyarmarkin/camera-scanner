//
//  SessionSettingsTableViewController.swift
//  camera
//
//  Created by Данила Ярмаркин on 19.06.2021.
//

import UIKit
//import Photos

class SessionSettingsTableViewController: UITableViewController {
    
    var sessionsData = [["HFUI"], ["KMKS"], ["IFIB"], ["FHWI"], ["QOJC"], ["PAFF"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem

//        LocalStorage.removeArrayElement(key: LocalStorage.sessionArray, index: 0)
        let updateSessions = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: {(timer) in
            let val = LocalStorage.getArray(key: LocalStorage.sessionArray)
            if let v = val as? [[String]] {
                if v != self.sessionsData {
                    self.sessionsData = v
                    self.tableView.reloadData()
                }
            }
            let v = val[0]
        })
        updateSessions.tolerance = 0.2

        UIApplication.shared.isIdleTimerDisabled = true

//        let videosArray = PHAsset.fetchAssets(with: .video, options: nil)
//        videosArray[0]
//        exportVideo()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessionsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SessionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SessionTableViewCell
        
        cell.configure(text: sessionsData[indexPath[1]][0])

//        print(indexPath)

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // MARK: Delete Rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LocalStorage.removeArrayElement(key: LocalStorage.sessionArray, index: indexPath[1])
            sessionsData.remove(at: indexPath[1])
//            self.tableView.reloadData()
            print("reloaded")
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            tableView.insertRows(at: [indexPath], with: .fade)
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

    func exportVideo(url: String = "file:///var/mobile/Containers/Data/Application/8AD37CFE-0366-4D43-AED5-7799A4457854/Documents/SRRO.mov") {

        var filePath = url
//        let filePath = Bundle.main.path(forResource: url, ofType: "mov") ?? nil

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("path = \(paths)")
        let fileUrl = paths[0].appendingPathComponent("\(url).mov")
        filePath = fileUrl.path

        if filePath == nil {
            print("url unavailable")
            return
        }
        let videoLink = NSURL(fileURLWithPath: filePath)

        let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Session", forKey: "subject")

        self.present(activityVC, animated: true, completion: nil)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
        print("\(indexPath) clicked")
        exportVideo(url: sessionsData[indexPath[1]][0])
    }
}
