//
//  SettingsViewController.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 02/07/19.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var serverUrl: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Settings"
        serverUrl.layer.cornerRadius = 5.0
        serverUrl.layer.borderWidth = 1.0
        serverUrl.layer.borderColor = UIColor.blue.cgColor
        saveBtn.layer.cornerRadius = 5.0
        if let url = UserDefaults.standard.url(forKey: "ServerUrl") {
            serverUrl.text = url.absoluteString
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(false, animated:true);
    }
    
    @IBAction func saveBtnAct(_ sender: Any) {
        let url = URL.init(string: serverUrl.text)
        if url != nil{
            UserDefaults.standard.set(url, forKey: "ServerUrl")
            self.navigationController?.popViewController(animated: true)
        }else{
            self.view.showToast("Url is Not valid", width: 200)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
