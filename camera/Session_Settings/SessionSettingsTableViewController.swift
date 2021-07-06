//
//  SessionSettingsTableViewController.swift
//  camera
//
//  Created by Данила Ярмаркин on 19.06.2021.
//

import UIKit
import AVFoundation
import Firebase
//import Photos

class SessionSettingsTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    
    var sessionsData = [["AAAA"]]
    var trashData: [String] = ["AAAA"]
    var previewData: Dictionary<String, UIImage> = ["AAAA": UIImage.init(systemName: "paperplane.fill")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let updateSessions = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: {(timer) in
            let val = LocalStorage.getArray(key: LocalStorage.sessionArray)
            let trashList = LocalStorage.getArray(key: LocalStorage.trashList)
            if let v = val as? [[String]]{
                if v != self.sessionsData{
                    self.sessionsData = v
                    self.tableView.reloadData()
                }
            }
            if let trash = trashList as? [String] {
                if trash != self.trashData {
                    print("updating trash list")
                    self.trashData = trash
                    print(trash)
                    self.tableView.reloadData()
                }
            }
        })
        updateSessions.tolerance = 0.2

        UIApplication.shared.isIdleTimerDisabled = true
        
        monitoringData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        }
        return sessionsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath[0] == 0 {
            let cell: SessionGroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "session_group_cell") as! SessionGroupTableViewCell
            if indexPath[1] == 0 {
                cell.configure(name: "Export all good session", color: .systemBlue)
            } else {
                cell.configure(name: "Delete trash list", color: .systemRed)
            }
            return cell
        }
        let cell: SessionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SessionTableViewCell
        let session = sessionsData[indexPath[1]][0]
        if session.count <= 4 {
            cell.configure(text: session, switchVal: false)
            return cell
        }
        if !previewData.keys.contains(session) {
            previewData[session] = preview(videoURL: session)
        }
        if trashData.contains(session) {
            print("trash: \(session)")
            cell.configure(text: session, switchVal: false, previewImage: previewData[session]!, duration: videoDuration(videoURL: session))
        } else {
            cell.configure(text: session, switchVal: true, previewImage: previewData[session]!, duration: videoDuration(videoURL: session))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[0] == 0 {
            return 64.0
        }
        return 100.0
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath[0] == 0 { return false }
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Actions" }
        return "Sessions"
    }
    
    // MARK: Delete Rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ref.child("trashList").child(sessionsData[indexPath[1]][0]).setValue(nil)
            deleteVideo(url: sessionsData[indexPath[1]][0])
            LocalStorage.removeArrayStringElement(key: LocalStorage.trashList, value: sessionsData[indexPath[1]][0])
            LocalStorage.removeArrayElement(key: LocalStorage.sessionArray, index: indexPath[1])
            previewData.removeValue(forKey: sessionsData[indexPath[1]][0])
            sessionsData.remove(at: indexPath[1])
            if LocalStorage.getArray(key: LocalStorage.sessionArray).count == 0 {
                LocalStorage.set(key: LocalStorage.sessionArray, val: [["No Elements"]])
                sessionsData = [["No Elements"]]
            }
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
//        print("path = \(paths)")
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
    
    func deleteVideo(url: String) {
        var filePath = url
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("\(url).mov")
        filePath = fileUrl.path
        print("path = \(filePath)")
        let fm = FileManager()
        try? fm.removeItem(atPath: filePath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 0] {  // export good sessions
            
        } else if indexPath == [0, 1] {
            
        } else {
            exportVideo(url: sessionsData[indexPath[1]][0])
        }
    }
    
    func monitoringData() {
        ref.child("trashList").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                for i in val {
                    print("========")
                    if !self.trashData.contains(i.key) && i.value == 1{
                        self.trashData.append(i.key)
                        LocalStorage.appendArray(key: LocalStorage.trashList, value: i.key)
                        print("new value \(i.key)")
                    }
                    
                    if self.trashData.contains(i.key) && i.value == 0 {
                        for j in 0...self.trashData.count - 1 {
                            if self.trashData[j] == i.key {
                                self.trashData.remove(at: j)
                                LocalStorage.removeArrayStringElement(key: LocalStorage.trashList, value: i.key)
                                break
                            }
                        }
                        print("remove \(i.key)")
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
}


extension SessionSettingsTableViewController {
    func preview(videoURL: String) -> UIImage{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print("path = \(paths)")
        let fileUrl = paths[0].appendingPathComponent("\(videoURL).mov")
        let asset = AVAsset(url: fileUrl)
//        print(fileUrl)
//        let durationInSeconds = asset.duration.seconds
        let generator = AVAssetImageGenerator.init(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime.zero
        generator.requestedTimeToleranceAfter = CMTime.zero
        do {
            let cgImage = try generator.copyCGImage(at: CMTimeMake(value: Int64(1), timescale: 1000), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image
        } catch {
            return UIImage.init(systemName: "paperplane.fill")!
        }
    }
    
    func videoDuration(videoURL: String) -> Int{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print("path = \(paths)")
        let fileUrl = paths[0].appendingPathComponent("\(videoURL).mov")
        let asset = AVAsset(url: fileUrl)
//        print(fileUrl)
        let durationInSeconds = asset.duration.seconds
        return Int(durationInSeconds)
    }
}
