//
//  SessionExpiredView.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 21/12/19.
//

import UIKit

class SessionExpiredView: UIView {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var passwordTxt: UITextField!
    
    class func instanceFromNib() -> SessionExpiredView {
        let expiredView = UINib(nibName: "SessionExpiredView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SessionExpiredView
        expiredView.frame = UIScreen.main.bounds
        expiredView.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        expiredView.setShadowTableCellView()
        return expiredView
    }
    @IBAction func submitAct(_ sender: Any) {
        if self.passwordTxt.text!.count > 0 {
            if self.passwordTxt.text! == userPassword {
                self.showToast("Authenticated Successfully", width: 250)
                self.removeFromSuperview()
            }else{
                self.showToast("Please enter the valid password", width: 250)
            }
        }else{
            self.showToast("Please enter the password", width: 250)
        }
    }
    
    
    func setShadowTableCellView() {
        
        self.subView.layer.shadowColor    = UIColor.lightGray.cgColor
        self.subView.layer.shadowOpacity  = 0.7
        self.subView.layer.shadowRadius   = 2.0
        self.subView.layer.shadowOffset   = CGSize(width: 0, height: 1)
        self.subView.layer.cornerRadius   = 5.0
        self.subView.layer.borderWidth    = 0.1
        self.subView.layer.masksToBounds  = false
        self.subView.clipsToBounds  = true
    }

}
