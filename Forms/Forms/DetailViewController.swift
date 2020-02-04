//
//  DetailViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 17/06/19.
//

import UIKit

class DetailViewController: UIViewController,DateDelegate,DropDownDelegate {
    @IBOutlet var tableView:UITableView!
    var titleLabel: UILabel = UILabel()
    var detailDict: SectionModel!
    var selectedElement:SectionModel!
    
    var isBMI:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        titleLabel.text = detailDict.name
        
        if detailDict.code == "bmi" {
            self.isBMI = true
        }
        self.navigationItem.setHidesBackButton(false, animated:true);

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
        
        print("dateClicked\(String(describing: sender.code))")
        selectedElement = sender.childElement
        let dateSeletcionViewController = DateSelectionViewController()
        dateSeletcionViewController.code = sender.code
        dateSeletcionViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        dateSeletcionViewController.dateDelegate = self
        self.navigationController?.present(dateSeletcionViewController, animated: true, completion: nil)
    }
    
    @objc func checkBoxClicked(sender: CustomSwitch) {
        print("checkBoxClicked\(String(describing: sender.code))")
        
        sender.childElement!.value.removeAll()
        sender.childElement!.value.append(sender.isOn ? "True" : "false")
        self.tableView.reloadData()

    }
    
    func displaySelectedDate(dateStr: String?, key: String?) {
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


extension DetailViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailDict.childList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let childElement =  detailDict.childList![indexPath.row]
//        let childElementType = childElement.type
//        var cellHeight = 65
//        if childElementType.elementsEqual("group") || childElementType.elementsEqual("CheckBox") || childElementType.elementsEqual("PlainText") {
//            cellHeight = 44
//        }
//        if childElementType.elementsEqual("TextBox") || childElementType.elementsEqual("DateTime") || childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect") {
//            cellHeight = 65
//        }
//        if childElementType.elementsEqual("TextArea")  {
//            cellHeight = 120
//        }
//        return CGFloat(cellHeight)
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childElement = detailDict.childList![indexPath.row]
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
        if childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect"){
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
        if (cell.checkBox != nil)
        {
            cell.checkBox.isOn = aValue == "True" ? true : false
            cell.checkBox.code = code
            cell.checkBox.childElement = childElement
            cell.checkBox.addTarget(self, action: #selector(checkBoxClicked) , for: UIControl.Event.touchUpInside);
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let childElement = self.detailDict.childList![indexPath.row]
        let childElementType = childElement.type
        if childElementType.elementsEqual("group") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewController.detailDict = childElement
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}
extension DetailViewController: UITextFieldDelegate, UITextViewDelegate
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
        if isBMI {
            self.calculateBMI()
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
        if isBMI {
            self.calculateBMI()
        }
        
        return true
    }
    
    func calculateBMI() {
        var height:Float = 0
        var weight:Float = 0
        
        for sectionModel in detailDict.childList! {
            if sectionModel.code == "height" {
                if sectionModel.value.count > 0 {
                    height = Float(sectionModel.value[0]) ?? 0
                }
            }else if sectionModel.code == "weight" {
                if sectionModel.value.count > 0 {
                    weight = Float(sectionModel.value[0]) ?? 0
                }
            }
        }
        
        let heightInMeters = height/100.0
        if heightInMeters > 0 {
            let bmiValue = weight / (heightInMeters * heightInMeters)
            self.detailDict.value.removeAll()
            self.detailDict.value.append("\(bmiValue)")
        }
        
    }
}


