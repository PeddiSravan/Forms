//
//  HomeViewController.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 02/07/19.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var normalUserView: UIView!
    
    @IBOutlet weak var usersTable: UITableView!
    var isAdmin:Bool = false
    var selectedUser:String = ""
    var addButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Forms"
        self.logoutBtn()
        if isAdmin {
            self.title = "Patient List"
            self.normalUserView.isHidden = true
            self.addAddUserBtnInNav()
        }else{
            self.usersTable.isHidden = true
        }
    }
    
    func logoutBtn() {
        let logoutBtn = UIButton.init(type: .custom)
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.setTitleColor(UIColor.blue, for: .normal)
        logoutBtn.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        logoutBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let saveBarButtonItem = UIBarButtonItem.init(customView: logoutBtn)
        self.navigationItem.leftBarButtonItem = saveBarButtonItem
    }
    
    func addAddUserBtnInNav() {
        let addButton = UIButton.init(type: .custom)
      //  addButton.setTitle("Add User", for: .normal)
        addButton.setImage(#imageLiteral(resourceName: "ellipsis"), for: .normal)
        addButton.setTitleColor(UIColor.blue, for: .normal)
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.addTarget(self, action: #selector(addNewUser), for: .touchUpInside)
        let saveBarButtonItem = UIBarButtonItem.init(customView: addButton)
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    @objc func addNewUser(_sender:UIBarButtonItem) {
        //        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        //        let createVC = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        //        createVC.isForUser = true
        //        self.navigationController!.pushViewController(createVC, animated: true)
        let popup = AlloyPopUpController(nibName: "AlloyPopUpController", bundle: nil)
        popup.delegate = self
        popup.options = ["New User","Settings"]
        popup.modalPresentationStyle = .popover
        if let presentation = popup.popoverPresentationController {
            presentation.barButtonItem = navigationItem.rightBarButtonItem
        }
        popup.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        popup.popoverPresentationController?.sourceView = self.view
        popup.popoverPresentationController?.delegate = self
        popup.preferredContentSize = CGSize(width: 150, height: 100)
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc func logoutUser() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.usersTable.reloadData()
    }
    
    @IBAction func createNewFormAct(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func historyBtnAct(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if( !(cell != nil))
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = usersList[indexPath.row].userName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        selectedUser = usersList[indexPath.row].userName
        let popup = AlloyPopUpController(nibName: "AlloyPopUpController", bundle: nil)
        popup.delegate = self
        popup.options = ["Edit User","Delete User"]
        popup.modalPresentationStyle = .popover
        popup.popoverPresentationController?.sourceRect = cell!.bounds
        popup.popoverPresentationController?.sourceView = cell
        popup.popoverPresentationController?.delegate = self
        popup.preferredContentSize = CGSize(width: 150, height: 100)
        self.present(popup, animated: true, completion: nil)
    }
//    func popUpFunc(options : [String],sourcRect : CGSize ,sourcView : CGRect) -> Void {
//
//    }
    
    
}
extension HomeViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }
}

extension HomeViewController : SeletedItem {
    func selectedItem(_ item: String) {
        if item == "Edit User" {
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let createVC = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
            createVC.isForUser = true
            createVC.selectedUser = self.selectedUser
            self.navigationController!.pushViewController(createVC, animated: true)
        }else if item == "Delete User"{
            let alertController = UIAlertController(title: "", message: "You Want to Delete The User.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
                DispatchQueue.main.async {
                    usersList.removeAll { (user) -> Bool in
                        user.userName == self.selectedUser
                    }
                    self.usersTable.reloadData()
                    let httpBody = try? JSONEncoder().encode(usersList)
                    UserDefaults.standard.set(httpBody, forKey: "UsersList")
                    UserDefaults.standard.synchronize()
                    self.view.showToast("User Deleted Successfully!", width: 300)
                }
            }
            let cancelAction = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
                
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else if item == "New User" {
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let createVC = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
            createVC.isForUser = true
            self.navigationController!.pushViewController(createVC, animated: true)
        } else {
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}
