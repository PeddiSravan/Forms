//
//  HistoryViewController.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 02/07/19.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTable: UITableView!
    var historyList:[String] = []
    var selectedList:[String] = []
    var savedList:[String] = []
    var isUserSelected:Bool = false
    
    @IBOutlet weak var deleteOrUploadView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Patient Records"
        self.historyTable.delegate = self
        self.historyTable.dataSource = self
        
        self.getHistoryFiles()
        self.deleteOrUploadView.isHidden = true
    }
    
    func getHistoryFiles() {
        if let historyList = UserDefaults.standard.value(forKey: UserdefaultKeys.shared.forumName) as? [String] {
            self.historyList = historyList
            self.addUploadAllBtnInNav()
        }
    }
    
    func addUploadAllBtnInNav() {
        let saveButton = UIButton.init(type: .custom)
        if isUserSelected {
            saveButton.setTitle("Cancel", for: .normal)
        }else {
            saveButton.setTitle("Select", for: .normal)
        }
        saveButton.setTitleColor(UIColor.blue, for: .normal)
        saveButton.addTarget(self, action: #selector(uploadAllToServer), for: .touchUpInside)
        saveButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let saveBarButtonItem = UIBarButtonItem.init(customView: saveButton)
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    @objc func uploadAllToServer() {
        self.deleteOrUploadView.isHidden = true
        isUserSelected = !isUserSelected
        self.addUploadAllBtnInNav()
        self.selectedList = []
        self.historyTable.reloadData()
    }
    @IBAction func deleteSelectedItems(_ sender: Any) {
        
        let alertController = UIAlertController(title: "", message: "You Want Delete The Selected Patients.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            DispatchQueue.main.async {
                if var historyList = UserDefaults.standard.value(forKey: UserdefaultKeys.shared.forumName) as? [String] {
                    historyList.removeAll { (str) -> Bool in
                        self.selectedList.contains(str)
                    }
                    UserDefaults.standard.set(historyList, forKey: UserdefaultKeys.shared.forumName)
                    UserDefaults.standard.synchronize()
                }
                self.deleteOrUploadView.isHidden = true
                self.isUserSelected = false
                self.addUploadAllBtnInNav()
                self.historyList = []
                self.getHistoryFiles()
                self.historyTable.reloadData()
                self.view.showToast("Selected Patients Deleted Successfully!", width: 300)
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadSelectedItems(_ sender: Any) {
        if self.selectedList.count > 0 {
            if UserDefaults.standard.url(forKey: "ServerUrl") != nil {
                self.callService()
                self.showLoader("Uploading Patient...")
            }else{
                self.view.showToast("Please Enter the server url", width: 200)
            }
        }else{
            self.view.showToast("Please select atleast one", width: 200)
        }
    }
    
    
    func callService(_ currentCount:Int = 0) {
        var currentCount = currentCount
        let decoded  = UserDefaults.standard.data(forKey: self.selectedList[currentCount])
        if decoded != nil {
            self.callServiceForSavingDetails(decoded!, fileName: self.selectedList[currentCount]) {
                currentCount = currentCount + 1
                if currentCount < self.selectedList.count {
                    self.callService(currentCount)
                }else{
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                        if var historyList = UserDefaults.standard.value(forKey: UserdefaultKeys.shared.forumName) as? [String] {
                            historyList.removeAll { (str) -> Bool in
                                self.savedList.contains(str)
                            }
                            UserDefaults.standard.set(historyList, forKey: UserdefaultKeys.shared.forumName)
                            UserDefaults.standard.synchronize()
                        }
                        self.deleteOrUploadView.isHidden = true
                        self.isUserSelected = false
                        self.addUploadAllBtnInNav()
                        if self.savedList.count > 0 {
                            self.view.showToast("Deatails Uploaded to server!", width: 200)
                        }
                        self.historyList = []
                        self.getHistoryFiles()
                        self.historyTable.reloadData()
                    }
                }
            }
        }
    }
    
    func callServiceForSavingDetails(_ jsonData:Data,fileName:String,completion: (() -> Void)?) {
        if let serviceUrl = UserDefaults.standard.url(forKey: "ServerUrl") {
            
            var request = URLRequest(url: serviceUrl as URL)
            request.httpMethod = "POST"
            let boundary = "------WebKitFormBoundaryXflTCEkIPERP1zB5"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let fileNameToServer = "\(fileName).json"
            let body = NSMutableData()
            body.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data;type=\"file\"; name=\"upload\";filename=\"\(fileNameToServer)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(jsonData)
            body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            body.appendString("Content-Disposition: form-data; name=\"inputFiles\"\r\n\r\n")
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            request.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
            request.httpBody = body as Data
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    DispatchQueue.main.async {
                        self.view.showToast("\(error.localizedDescription)", width: 200)
                    }
                    if completion != nil{
                        completion!()
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        print ("server error")
                        DispatchQueue.main.async {
                            self.view.showToast("server error", width: 200)
                        }
                        if completion != nil{
                            completion!()
                        }
                        return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        DispatchQueue.main.async {
                            if let internalData = json as? NSArray, internalData.count > 0 {
                                self.savedList.append(fileName)
                            }else{
                                self.view.showToast("Please try again", width: 200)
                            }
                        }
                    }
                    catch{
                        DispatchQueue.main.async {
                            self.view.showToast("Please try again", width: 200)
                        }
                    }
                }
                if completion != nil{
                    completion!()
                }
            }
            task.resume()
        }else{
            DispatchQueue.main.async {
                self.view.showToast("Please Enter the URL in the settings", width: 300)
            }
        }
    }

}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        let docName = self.historyList[indexPath.row]
        cell.titleLbl.text = docName
        if isUserSelected {
            if selectedList.contains(docName) {
                cell.checkBox.image = UIImage(named: "checked")
            }else{
                cell.checkBox.image = UIImage(named: "unchecked")
            }
            cell.widthConstraint.constant = 30
        }else{
            cell.widthConstraint.constant = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isUserSelected {
            let docName = self.historyList[indexPath.row]
            if self.selectedList.contains(docName) {
                selectedList.removeAll { (str) -> Bool in
                    str == docName
                }
            }else{
                self.selectedList.append(docName)
            }
            if self.selectedList.count > 0 {
                self.deleteOrUploadView.isHidden = false
            }else{
                self.deleteOrUploadView.isHidden = true
            }
            self.historyTable.reloadData()
        }else{
            let userDefaults = UserDefaults.standard
            let decoded  = userDefaults.data(forKey: self.historyList[indexPath.row])
            do {
                if decoded != nil {
                    let formsModel = try JSONDecoder().decode(FormsModel.self, from: decoded!)
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    vc.formsModel = formsModel
                    vc.storedKey = self.historyList[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            catch{
                print(error)
            }
        }
    }
}

extension UIViewController {
    func showLoader(_ message:String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
}
