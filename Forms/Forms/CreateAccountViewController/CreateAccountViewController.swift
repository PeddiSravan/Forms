//
//  CreateAccountViewController.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 08/12/19.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createAdminAccount: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var selectedUser:String = ""
    
    var isForUser:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isForUser {
            self.title = "User Account"
            self.createAdminAccount.text = "Create User Account"
        }
        self.userName.delegate = self
        self.password.delegate = self
        
        if selectedUser != "" {
            let currentUser = usersList.filter { (user) -> Bool in
                user.userName == selectedUser
            }
            self.userName.text = currentUser.first?.userName
            self.password.text = currentUser.first?.password
            self.title = "Edit User"
            self.createAdminAccount.text = "Save Changes"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isForUser {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        if self.userName.text!.count > 0 && self.password.text!.count > 0 {
            if isForUser {
                if selectedUser != "" {
                    usersList.removeAll { (user) -> Bool in
                        user.userName == self.selectedUser
                    }
                }
                let userDetails = UserModel(userName: self.userName.text!, password: self.password.text!)
                usersList.append(userDetails)
                let httpBody = try? JSONEncoder().encode(usersList)
                UserDefaults.standard.set(httpBody, forKey: "UsersList")
                UserDefaults.standard.synchronize()
                self.navigationController?.popViewController(animated: false)
            }else{
                UserDefaults.standard.set(true, forKey: "IsAdminAvailable")
                UserDefaults.standard.set(self.userName.text, forKey: "adminUserName")
                UserDefaults.standard.set(self.password.text, forKey: "adminPassword")
                UserDefaults.standard.synchronize()
                self.goToLoginPage()
            }
        }else{
            self.view.showToast("Please enter the credentials", width: 250)
        }
    }
    
    func goToLoginPage() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController!.pushViewController(homeVC, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
