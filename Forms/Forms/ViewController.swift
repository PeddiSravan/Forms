//
//  ViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 11/06/19.
//

import UIKit
import Alamofire


class ViewController: UIViewController,DateDelegate,DropDownDelegate {

    var mainDict: [String : AnyObject]?
    var sectionsArray: [AnyObject] = [AnyObject]()
    @IBOutlet var tableView:UITableView!
    var expandedSections: [Int] = [Int]()
    var titleLabel: UILabel = UILabel()
    
    var selectedElement:SectionModel!
    
    var formsModel:FormsModel!
    
    var storedKey:String = ""
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var formNameTxt: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.tableFooterView = UIView()
        let rect = CGRect(x: 0, y: 0, width: 240, height: 44)

        let titleView = UIView(frame: rect)
        titleLabel.frame = rect;
        titleLabel.text = ""
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = NSTextAlignment.center
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        self.addSaveBtnInNav()
        self.subView.layer.cornerRadius = 5.0
        self.subView.layer.borderWidth = 1.0
        self.subView.layer.shadowRadius = 3.0
        self.fetchJsonDataFromFile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationItem.hidesBackButton = true
        var leftTitle = "Home"
        if storedKey != "" {
            leftTitle = "Patient Records"
        }
        let newBackButton = UIBarButtonItem(title: leftTitle, style: UIBarButtonItem.Style.plain, target: self, action: #selector(backClicked))
        self.navigationItem.leftBarButtonItem = newBackButton

    }
    
    @objc func backClicked() {
        
        let alertController = UIAlertController(title: "", message: "You Want Save The Changes.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            self.saveDataToUserDefaults()
        }
        let cancelAction = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tableView.reloadData()
    }
    
    func addSaveBtnInNav() {
        let saveButton = UIButton.init(type: .custom)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.setTitleColor(UIColor.blue, for: .normal)
        saveButton.addTarget(self, action: #selector(saveDataToUserDefaults), for: .touchUpInside)
        saveButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let saveBarButtonItem = UIBarButtonItem.init(customView: saveButton)
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    @objc func saveDataToUserDefaults() {
        if storedKey == "" {
            self.mainView.isHidden = false
        }else{
            saveDataIntoUserDefaults()
        }
    }
    @IBAction func closeBtnAct(_ sender: Any) {
        self.mainView.isHidden = true
    }
    @IBAction func saveBtnAction(_ sender: Any) {
        if self.formNameTxt.text!.count > 0  {
            storedKey = self.formNameTxt.text!
            saveDataIntoUserDefaults()
            self.mainView.isHidden = true
        }else{
            self.view.showToast("Please Enter the Form Name", width: 250)
        }
    }
    
    func saveDataIntoUserDefaults() {
        let userDefaults = UserDefaults.standard
        formsModel.username = username
        let httpBody = try? JSONEncoder().encode(formsModel)
        userDefaults.set(httpBody, forKey: storedKey)
        userDefaults.synchronize()
        self.view.showToast("Details Saved Successfully!", width: 200)
        
        if var historyList = UserDefaults.standard.value(forKey: UserdefaultKeys.shared.forumName) as? [String] {
            if !historyList.contains(storedKey){
                historyList.append(storedKey)
            }
            userDefaults.set(historyList, forKey: UserdefaultKeys.shared.forumName)
            userDefaults.synchronize()
        }else{
            let historyList = [storedKey]
            userDefaults.set(historyList, forKey: UserdefaultKeys.shared.forumName)
            userDefaults.synchronize()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func callServiceForSavingDetails(_ jsonData:Data) {
        if let serviceUrl = UserDefaults.standard.url(forKey: "ServerUrl") {
            var request = URLRequest(url: serviceUrl as URL)
            request.httpMethod = "POST"
            let boundary = "------WebKitFormBoundaryXflTCEkIPERP1zB5"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = NSMutableData()
            body.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data;type=\"file\"; name=\"upload\";filename=\"\(storedKey)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(jsonData)
            body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            body.appendString("Content-Disposition: form-data; name=\"inputFiles\"\r\n\r\n")
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            request.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
            request.httpBody = body as Data
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                if let error = error {
                    print ("error: \(error)")
                    DispatchQueue.main.async {
                        self.view.showToast("\(error.localizedDescription)", width: 200)
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        print ("server error")
                        DispatchQueue.main.async {
                            self.view.showToast("server error", width: 200)
                        }
                        return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        DispatchQueue.main.async {
                            if let internalData = json as? NSArray, internalData.count > 0 {
                                self.view.showToast("Deatails Uploaded to server!", width: 200)
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
            }
            task.resume()
        }else{
            DispatchQueue.main.async {
                self.view.showToast("Please Enter the URL in the settings", width: 300)
            }
        }
    }
    
    private func fetchJsonDataFromFile() {
        if self.formsModel == nil {
            //Check jsonObject is valid or not
            guard let url = Bundle.main.url(forResource: "Form", withExtension: "json") else { return }
            do {
                let data = try Data(contentsOf: url)
                let model: FormsMainModel = try JSONDecoder().decode(FormsMainModel.self, from: data)
                self.formsModel = model.form
                titleLabel.text = self.formsModel.name
                
                let userreview = self.formsModel.sections.last?.childList?.last
                if userreview != nil {
                    userreview?.childList?.first?.value.append(username)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    userreview?.childList?.last?.value.append(dateFormatter.string(from: Date()))
                }
                
                
                self.tableView.reloadData()
            }catch {
                print(error.localizedDescription)
            }
        }else{
            titleLabel.text = self.formsModel.name
        }
    }
    @objc func dropDownClicked(sender: CustomButton) {
        print("dropDownClicked\(String(describing: sender.code))")
        
        let options = sender.childElement?.options
        let type = sender.childElement?.type
        selectedElement = sender.childElement

        let dropDownSelectionViewController = DropDownSelectionViewController()
        dropDownSelectionViewController.code = sender.code
        dropDownSelectionViewController.dropDownDelegate = self
        dropDownSelectionViewController.dropDownValues = options ?? []
        dropDownSelectionViewController.dropDownType = type ?? ""
        dropDownSelectionViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(dropDownSelectionViewController, animated: true, completion: nil)
    }
    
    @objc func dateClicked(sender: CustomButton) {
        selectedElement = sender.childElement
        print("dateClicked\(String(describing: sender.code))")
        let dateSeletcionViewController = DateSelectionViewController()
        dateSeletcionViewController.code = sender.code
        dateSeletcionViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        dateSeletcionViewController.dateDelegate = self
        self.navigationController?.present(dateSeletcionViewController, animated: true, completion: nil)
    }
    func displaySelectedDate(dateStr: String?, key: String?) {
        print("Date \(String(describing: dateStr))For Key\(String(describing: key))")
        selectedElement.value.removeAll()
        selectedElement.value.append(dateStr!)
        self.tableView.reloadData()
    }
    func displaySelectedDropDownValue(dropDownValue: String?, key: String?) {
        selectedElement.value.removeAll()
        selectedElement.value.append(dropDownValue!)
        self.tableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.formsModel != nil {
            return self.formsModel.sections.count//sectionsArray.count
        }else{
            return 0
        }
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        var isExpand = false
        if self.formsModel != nil {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if !expandedSections.contains(section){
                    return self.formsModel.sections[section].childList!.count
                }
            }else{
                if expandedSections.contains(section){
                    return self.formsModel.sections[section].childList!.count
                }
            }
        }
        
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let childElementType = self.formsModel.sections[indexPath.section].childList![indexPath.row].type
//        var cellHeight = 65
//        if childElementType.elementsEqual("group") || childElementType.elementsEqual("CheckBox") || childElementType.elementsEqual("PlainText") {
//            cellHeight = 44
//        }
//        if childElementType.elementsEqual("TextBox") || childElementType.elementsEqual("DateTime") || childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect") {
//            cellHeight = 65
//        }
//        if childElementType.elementsEqual("TextArea") {
//            cellHeight = 120
//        }
//        return CGFloat(cellHeight)
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childElement = self.formsModel.sections[indexPath.section].childList![indexPath.row]
        let childElementType = childElement.type

        var indexToDisplay = 0
        if childElementType.elementsEqual("group") {
            indexToDisplay = 0
        }
        if childElementType.elementsEqual("TextBox") {
            indexToDisplay = 1
        }
        if childElementType.elementsEqual("TextArea") {
            indexToDisplay = 2
        }
        if childElementType.elementsEqual("DateTime") {
            indexToDisplay = 3
        }
        if childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect") {
            indexToDisplay = 4
        }
        if childElementType.elementsEqual("CheckBox") {
            indexToDisplay = 5
        }
        if childElementType.elementsEqual("PlainText") {
            indexToDisplay = 6
        }

        let cells = Bundle.main.loadNibNamed("FormCell", owner: self, options:nil)
        let cell = cells?[indexToDisplay] as! FormCell
        cell.titleLabel.text = childElement.name
        cell.titleLabel.sizeToFit()
        
        if childElement.code == "bmi" && childElement.value.count > 0 {
            cell.titleLabel.text = "\(childElement.name)(\(childElement.value[0]))"
        }
        let code = childElement.code
        var aValue = ""
        if childElement.value.count > 0  {
            aValue = childElement.value[0]
        }

        if (cell.textField != nil) {
            cell.textField.code = code
            cell.textField.childElement = childElement
            cell.textField.text = aValue
            cell.textField.delegate = self
        }
        if (cell.textArea != nil) {
            cell.textArea.code = code
            cell.textArea.childElement = childElement
            cell.textArea.text = aValue
            cell.textArea.delegate = self
        }
        if (cell.dateButton != nil)
        {
            cell.dateButton.code = code
            cell.dateButton.childElement = childElement
            cell.dateButton.addTarget(self, action: #selector(dateClicked) , for: UIControl.Event.touchUpInside);
        }
        if (cell.dropDownButton != nil)
        {
            cell.dropDownButton.code = code
            cell.dropDownButton.childElement = childElement
            cell.dropDownButton.addTarget(self, action: #selector(dropDownClicked) , for: UIControl.Event.touchUpInside);
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let childElement = self.formsModel.sections[indexPath.section].childList![indexPath.row]
        let childElementType = childElement.type

        if childElementType.elementsEqual("group") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewController.detailDict = childElement
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = UIColor.init(red: 254/255.0, green: 198/255.0, blue: 70/255.0, alpha: 1.0)
        let labelRect = CGRect(x: 5, y: 0, width: rect.size.width-40, height: 44)

        let labelToDisplay = UILabel(frame: labelRect)
        labelToDisplay.font = UIFont.systemFont(ofSize: 20)
        labelToDisplay.text = self.formsModel.sections[section].name
        labelToDisplay.textColor = UIColor.white
        footerView.addSubview(labelToDisplay)
        
        let expandButtonRect = CGRect(x: rect.size.width - 35, y: 7, width: 30, height: 30)

        let expandButton = UIButton(frame: expandButtonRect)
        expandButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        expandButton.isUserInteractionEnabled = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            if !expandedSections.contains(section) {
                expandButton.setTitle("-", for: UIControl.State.normal)
            }else{
                expandButton.setTitle("+", for: UIControl.State.normal)
            }
        }else{
            if expandedSections.contains(section) {
                expandButton.setTitle("-", for: UIControl.State.normal)
            }else{
                expandButton.setTitle("+", for: UIControl.State.normal)
            }
        }
        expandButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        footerView.addSubview(expandButton)

        
        let lineRect = CGRect(x: 0, y: rect.size.height-1, width: rect.size.width, height: 1)
        let lineView = UIView(frame:lineRect)
        lineView.backgroundColor = UIColor.white
        footerView.addSubview(lineView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))

        footerView.tag = section
        footerView.addGestureRecognizer(tap)

        return footerView
    }
    // function which is triggered when handleTap is called
    @objc func handleTap(_ tapRecognizer: UITapGestureRecognizer) {
        let tag = tapRecognizer.view?.tag
        if expandedSections.contains(tag ?? 0){
            expandedSections.remove(object: tag ?? 0)
        }else{
            expandedSections.append(tag ?? 0)
        }
        self.tableView.reloadData()
    }

}

extension ViewController: UITextFieldDelegate, UITextViewDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.elementsEqual("\n")
        {
            textView.resignFirstResponder()
            return false
        }
        if let customeTextField = textView as? CustomTextView {
            let selectedModel = customeTextField.childElement
            var finalTxt:String = textView.text!
            if range.length == 0 {
                finalTxt = finalTxt + text
            }else{
                finalTxt = String(finalTxt.dropLast())
            }
            selectedModel?.value.removeAll()
            selectedModel?.value.append(finalTxt)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let customeTextField = textField as? CustomTextField {
            let selectedModel = customeTextField.childElement
            var finalTxt = textField.text!
            if range.length == 0 {
                finalTxt = finalTxt + string
            }else{
                finalTxt = String(finalTxt.dropLast())
            }
            selectedModel?.value.removeAll()
            selectedModel?.value.append(finalTxt)
        }
        return true
    }
}
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = index(of: object) else {return}
        remove(at: index)
    }
    
}


extension UIView {
    func showToast(_ message : String, width: CGFloat) {
        let boundFrame:CGRect = UIScreen.main.bounds
        let toastLabel = UILabel(frame: CGRect(x: (boundFrame.size.width - width)/2, y: boundFrame.size.height-120, width: width, height: 35))
        toastLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        toastLabel.numberOfLines = 3
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 13.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIApplication.shared.keyWindow?.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension NSMutableData {
    
    func appendString(_ string: String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
