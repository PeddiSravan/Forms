//
//  SignInViewController.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 07/12/19.
//

import UIKit

var username:String = ""
var userPassword:String = ""

var usersList:[UserModel] = []

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginasAdmin: UIImageView!
    var asAdmin:Bool = false
    
    var adminUserName:String = ""
    var adminPassword:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userName.delegate = self
        self.password.delegate = self

        self.adminUserName = UserDefaults.standard.value(forKey: "adminUserName") as! String
        self.adminPassword = UserDefaults.standard.value(forKey: "adminPassword") as! String
        
        
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.data(forKey: "UsersList")
        do {
            if decoded != nil {
                let usersModel = try JSONDecoder().decode([UserModel].self, from: decoded!)
                usersList = usersModel
            }
        }
        catch{
            print(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.userName.text = ""
        self.password.text = ""
        
        UserDefaults.standard.set(false, forKey: "UserLogedIn")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func signInAction(_ sender: Any) {
        
        if self.userName.text!.count > 0 && self.password.text!.count > 0 {
            username = self.userName.text!
            userPassword = self.password.text!
            UserdefaultKeys.shared.forumName = "FormNames\(username)"
            if asAdmin {
                if self.userName.text?.lowercased() == self.adminUserName.lowercased() && self.password.text == self.adminPassword {
                    UserDefaults.standard.set(true, forKey: "UserLogedIn")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    homeVC.isAdmin = true
                    self.navigationController!.pushViewController(homeVC, animated: true)
                }else{
                    self.view.showToast("Please enter correct details", width: 250)
                }
            }else{
                if checkUserPresetOrNot() {
                    UserDefaults.standard.set(true, forKey: "UserLogedIn")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.navigationController!.pushViewController(homeVC, animated: true)
                }else{
                    self.view.showToast("User not found", width: 250)
                }
            }
        }else{
            self.view.showToast("Please enter the credentials", width: 250)
        }
    }
    
    func checkUserPresetOrNot() -> Bool {
        for userModel in usersList {
            if userModel.userName.lowercased() == self.userName.text?.lowercased() && userModel.password == self.password.text {
                return true
            }
        }
        return false
    }
    
    @IBAction func loginasAdminAction(_ sender: Any) {
        asAdmin = !asAdmin
        
        if asAdmin {
            self.loginasAdmin.image = UIImage(named: "checked")
        }else{
            self.loginasAdmin.image = UIImage(named: "unchecked")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
