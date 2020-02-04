//
//  AlloyPopUpController.swift
//  Alloy
//
//  Created by Moban K Michael on 11/04/2019.
//  Copyright © 2019 Yotta Limited. All rights reserved.
//

import UIKit

protocol SeletedItem {
    func selectedItem(_ item:String)
    
}

class AlloyPopUpController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var options         = [String]()
    var iconString      = [String]()
    var iconBackGroundColour = UIColor.white
    var delegate:SeletedItem! = nil

    fileprivate let cellIdentifier = "CELL"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension AlloyPopUpController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text        = options[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle         = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [unowned self] in
            self.delegate.selectedItem(self.options[indexPath.row])
        }
    }
}
