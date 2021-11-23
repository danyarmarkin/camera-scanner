//
//  SettingsViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 13.11.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var stabilization: UISegmentedControl!
    @IBOutlet weak var focus: UISegmentedControl!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        stabilization.selectedSegmentIndex = defaults.integer(forKey: "stabilization")
        focus.selectedSegmentIndex = defaults.integer(forKey: "focus")
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onStabilization(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "stabilization")
    }
    
    @IBAction func onFocusRange(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "focus")
    }
}
