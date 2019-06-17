//
//  ViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 11/06/19.
//

import UIKit

class ViewController: UIViewController {

    var mainDict: [String : AnyObject]?
    var sectionsArray: [AnyObject] = [AnyObject]()
    @IBOutlet var tableView:UITableView!
    var expandedSections: [Int] = [Int]()
    var titleLabel: UILabel = UILabel()

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
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        
        self.fetchJsonDataFromFile()

    }
    private func fetchJsonDataFromFile() {
        //Check jsonObject is valid or not
        guard let url = Bundle.main.url(forResource: "Form", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print(object)
            if let dictionary = object as? [String: AnyObject] {
                print("Dictionary \(dictionary)");
                mainDict = dictionary["form"] as? [String : AnyObject]
                let formName = mainDict?["name"] as? String
                titleLabel.text = formName
                sectionsArray = mainDict?["sections"] as! [AnyObject]
            }
        }catch {
            print(error.localizedDescription)
        }
    }


}

extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var isExpand = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            if !expandedSections.contains(section){
                let innerDict = sectionsArray[section]
                let childArray =  innerDict["childList"] as! [AnyObject]
                return childArray.count
            }
        }else{
            if expandedSections.contains(section){
                let innerDict = sectionsArray[section]
                let childArray =  innerDict["childList"] as! [AnyObject]
                return childArray.count
            }
        }
        
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let innerDict = sectionsArray[indexPath.section]
        let childArray =  innerDict["childList"] as! [AnyObject]
        let childElement = childArray[indexPath.row]
        let childElementType = childElement["type"] as! String
        var cellHeight = 65
        if childElementType.elementsEqual("group") || childElementType.elementsEqual("CheckBox") {
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
        let innerDict = sectionsArray[indexPath.section]
        let childArray =  innerDict["childList"] as! [AnyObject]
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
        if childElementType.elementsEqual("DropDown") || childElementType.elementsEqual("MultiSelect") || childElementType.elementsEqual("SingleSelect") {
            indexToDisplay = 4
        }
        if childElementType.elementsEqual("CheckBox") {
            indexToDisplay = 5
        }

        let cells = Bundle.main.loadNibNamed("FormCell", owner: self, options:nil)
        let cell = cells?[indexToDisplay] as! FormCell
        cell.titleLabel.text = childElement["name"] as? String
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let innerDict = sectionsArray[indexPath.section]
        let childArray =  innerDict["childList"] as! [AnyObject]
        let childElement = childArray[indexPath.row]
        let childElementType = childElement["type"] as! String
        if childElementType.elementsEqual("group") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewController.detailDict = childElement as? [String : AnyObject]
            self.navigationController?.pushViewController(detailViewController, animated: true)//present(detailViewController, animated:true, completion:nil)
        }

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let innerDict = sectionsArray[section]
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = UIColor.init(red: 30/255.0, green: 134/255.0, blue: 210/255.0, alpha: 1.0)
//        30 134 210
        let labelRect = CGRect(x: 5, y: 0, width: rect.size.width-40, height: 44)

        let labelToDisplay = UILabel(frame: labelRect)
        labelToDisplay.font = UIFont.systemFont(ofSize: 14)
        labelToDisplay.text = innerDict["name"] as? String
        labelToDisplay.textColor = UIColor.white
        footerView.addSubview(labelToDisplay)
        
        let expandButtonRect = CGRect(x: rect.size.width - 35, y: 7, width: 30, height: 30)

        let expandButton = UIButton(frame: expandButtonRect)
        expandButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
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
        expandButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
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
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = index(of: object) else {return}
        remove(at: index)
    }
    
}
