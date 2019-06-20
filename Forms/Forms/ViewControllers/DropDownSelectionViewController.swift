//
//  DropDownSelectionViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 20/06/19.
//

import UIKit

protocol DropDownDelegate: class {
    func displaySelectedDropDownValue(dropDownValue: String?,key: String?)    
}

class DropDownSelectionViewController: UIViewController {
    
    var code: String!
    var dropDownDelegate: DropDownDelegate?

    var dropDownType : String = String()
    var dropDownValues : [String] = [String]()
    var selectedValues : [String] = [String]()

    @IBOutlet var dropDownTableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dropDownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    @IBAction func doneClicked(sender: UIButton)
    {
        if selectedValues.count>0 {
            var finalString  = ""
            for str in selectedValues{
                finalString.append(str)
                finalString.append(",")
            }
            finalString = finalString.trimmingCharacters(in: CharacterSet.init(charactersIn: ","))
            self.dismiss(animated: true) {
                if self.dropDownDelegate != nil
                {
                    self.dropDownDelegate?.displaySelectedDropDownValue(dropDownValue: finalString, key: self.code)
                }
            }
        }else{
            let alertController = UIAlertController(title: "", message: "Please select atleast one item.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in

            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func cancelClicked(sender: UIButton)
    {
        self.dismiss(animated: true) {
            
        }
    }

}
extension DropDownSelectionViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownValues.count
}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dropDownValue  = dropDownValues[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = dropDownValue
        if selectedValues.contains(dropDownValue)
        {
         cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none

        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dropDownValue  = dropDownValues[indexPath.row]
        if self.dropDownType.elementsEqual("MultiSelect")
        {
            if selectedValues.contains(dropDownValues[indexPath.row])
            {
                selectedValues.remove(object: dropDownValue)
            }else{
                selectedValues.append(dropDownValue)
            }
        }else{
            if selectedValues.contains(dropDownValues[indexPath.row])
            {
                selectedValues.remove(object: dropDownValue)
            }else{
                selectedValues.removeAll()
                selectedValues.append(dropDownValue)
            }
        }
        tableView.reloadData()
    }
}
