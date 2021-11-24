//
//  SessionsTableViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 13.11.2021.
//

import UIKit

class SessionsTableViewController: UITableViewController {
    
    var files: [URL]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        files = getVideoFromDocumentsDirectory()
        
        let updateFilesTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {timer in
            self.updateFiles()
        }
        updateFilesTimer.tolerance = 1
    }
    
    func updateFiles() {
        if self.getVideoFromDocumentsDirectory() != self.files {
            self.files = self.getVideoFromDocumentsDirectory()
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {return 2}
        return getVideoFromDocumentsDirectory().count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == [0, 0] {
            let exportSessionsCell = tableView.dequeueReusableCell(withIdentifier: "export_all_good_sessions_cell") as! ExportAllSessionsTableViewCell
            exportSessionsCell.configure(urls: files)
            exportSessionsCell.delegate = self
            return exportSessionsCell
        }
        
        if indexPath == [0, 1] {
            let deleteAllSessionCell = tableView.dequeueReusableCell(withIdentifier: "delete_all_bad_sessions_cell") as! DeleteAllBadSessionsTableViewCell
            deleteAllSessionCell.configure(urls: files)
            deleteAllSessionCell.delegate = self
            return deleteAllSessionCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "session_cell", for: indexPath) as! SessionTableViewCell
        
        let files = getVideoFromDocumentsDirectory()
        cell.configure(url: files[files.count - 1 - indexPath[1]])
        cell.delegate = self
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath[0] == 0 { return false}
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFile(url: files[files.count - 1 - indexPath[1]])
            updateFiles()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


}

extension SessionsTableViewController {
    func getVideoFromDocumentsDirectory() -> [URL]{
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            let movFiles = directoryContents.filter{ $0.pathExtension == "mov" }
            return movFiles

        } catch {
            print(error)
        }
        return []
    }
    
    func deleteFile(url: URL) {
        let fileManager = FileManager()
        try? fileManager.removeItem(atPath: url.path)
    }
}
