//
//  NamingViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 30.11.2021.
//

import UIKit

class NamingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.delegate = self
        name.text = NamingConf.getNaming()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
      self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onName(_ sender: UITextField) {
        NamingConf.setNaming(sender.text ?? "O_nnnRRRRN_km_d_t")
        Server.setNaming(sender.text ?? "O_nnnRRRRN_km_d_t")
    }
}
