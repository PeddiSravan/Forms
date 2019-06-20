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
    var detailDict: [String : AnyObject]?
//    var codeValues: [String:String]?

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
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        titleLabel.text = detailDict?["name"] as? String
    }
    @objc func dropDownClicked(sender: CustomButton) {
        print("dropDownClicked\(String(describing: sender.code))")
        
        let options = sender.childElement?["options"]
        let type = sender.childElement?["type"]
        
        let dropDownSelectionViewController = DropDownSelectionViewController()
        dropDownSelectionViewController.code = sender.code
        dropDownSelectionViewController.dropDownDelegate = self
        dropDownSelectionViewController.dropDownValues = options as! [String]
        dropDownSelectionViewController.dropDownType = type as! String
        dropDownSelectionViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(dropDownSelectionViewController, animated: true, completion: nil)
    }

    @objc func dateClicked(sender: CustomButton) {
        
        print("dateClicked\(String(describing: sender.code))")
        let dateSeletcionViewController = DateSelectionViewController()
        dateSeletcionViewController.code = sender.code
        dateSeletcionViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        dateSeletcionViewController.dateDelegate = self
        self.navigationController?.present(dateSeletcionViewController, animated: true, completion: nil)
    }
    func displaySelectedDate(dateStr: String?, key: String?) {
        print("Date \(String(describing: dateStr))For Key\(String(describing: key))")
        codeValues[key ?? ""] = dateStr
        self.tableView.reloadData()
    }
    func displaySelectedDropDownValue(dropDownValue: String?, key: String?) {
        codeValues[key ?? ""] = dropDownValue
        self.tableView.reloadData()
    }
}


extension DetailViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let childArray =  detailDict?["childList"] as! [AnyObject]
        return childArray.count
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let childArray =  detailDict?["childList"] as! [AnyObject]
        let childElement = childArray[indexPath.row]
        let childElementType = childElement["type"] as! String
        var cellHeight = 65
        if childElementType.elementsEqual("group") || childElementType.elementsEqual("CheckBox")  {
            cellHeight = 44
        }
        if childElementType.elementsEqual("TextBox") || childElementType.elementsEqual("DateTime") || childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect") {
            cellHeight = 65
        }
        if childElementType.elementsEqual("TextArea") || childElementType.elementsEqual("PlainText") {
            cellHeight = 120
        }
        return CGFloat(cellHeight)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childArray =  detailDict?["childList"] as! [AnyObject]
        let childElement = childArray[indexPath.row]
        
        let childElementType = childElement["type"] as! String
        var indexToDisplay = 0
        if childElementType.elementsEqual("group") {
            indexToDisplay = 0
        }
        if childElementType.elementsEqual("TextBox") {
            indexToDisplay = 1
        }
        if childElementType.elementsEqual("TextArea") || childElementType.elementsEqual("PlainText") {
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
        let cells = Bundle.main.loadNibNamed("FormCell", owner: self, options:nil)
        let cell = cells?[indexToDisplay] as! FormCell
        cell.titleLabel.text = childElement["name"] as? String
        let code = childElement["code"] as! String
        var aValue =  codeValues[code]
        if aValue == nil {
            aValue = ""
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

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let childArray =  detailDict?["childList"] as! [AnyObject]
        let childElement = childArray[indexPath.row]
        let childElementType = childElement["type"] as! String
        if childElementType.elementsEqual("group") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewController.detailDict = childElement as? [String : AnyObject]
            self.navigationController?.pushViewController(detailViewController, animated: true)//present(detailViewController, animated:true, completion:nil)
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
        return true
    }
}


