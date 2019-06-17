//
//  DetailViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 17/06/19.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var tableView:UITableView!
    var titleLabel: UILabel = UILabel()
    var detailDict: [String : AnyObject]?

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
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let innerDict = sectionsArray[section]
//        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
//        let footerView = UIView(frame:rect)
//        footerView.backgroundColor = UIColor.blue
//        let labelRect = CGRect(x: 5, y: 0, width: rect.size.width-10, height: 44)
//
//        let labelToDisplay = UILabel(frame: labelRect)
//        labelToDisplay.font = UIFont.systemFont(ofSize: 14)
//        labelToDisplay.text = innerDict["name"] as? String
//        labelToDisplay.textColor = UIColor.white
//        footerView.addSubview(labelToDisplay)
//
//        let lineRect = CGRect(x: 0, y: rect.size.height-1, width: rect.size.width, height: 1)
//        let lineView = UIView(frame:lineRect)
//        lineView.backgroundColor = UIColor.white
//        footerView.addSubview(lineView)
//
//        //        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
//        //        tap.delegate = self as! UIGestureRecognizerDelegate
//        //        footerView.addGesture(tap)
//
//        //        let tap = UITapGestureRecognizer(target: self, action: Selector(("handleTap:")))
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//
//        footerView.tag = section
//        footerView.addGestureRecognizer(tap)
//
//        return footerView
//    }
//    // function which is triggered when handleTap is called
//    @objc func handleTap(_ tapRecognizer: UITapGestureRecognizer) {
//        print("Hello World")
//        let tag = tapRecognizer.view?.tag
//        if expandedSections.contains(tag ?? 0){
//            expandedSections.remove(object: tag ?? 0)
//        }else{
//            expandedSections.append(tag ?? 0)
//        }
//        self.tableView.reloadData()
//        //            expandedSections.
//    }
    
}

