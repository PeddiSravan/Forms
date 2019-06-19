//
//  DateSelectionViewController.swift
//  Forms
//
//  Created by Sravan Peddi on 18/06/19.
//

import UIKit

protocol DateDelegate: class {
//    func displaySelectedDate(date: NSDate?,key: String?)
    func displaySelectedDate(dateStr: String?,key: String?)

}
class DateSelectionViewController: UIViewController {

    @IBOutlet  var datePicker:UIDatePicker!
    var date: NSDate!
    var code: String!
    var dateDelegate: DateDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func doneClicked(sender: UIButton)
    {
//        NSDate *date = [self.datePicker date];
        let selectedDate = self.datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        self.dismiss(animated: true) {
            if self.dateDelegate != nil
            {
                self.dateDelegate?.displaySelectedDate(dateStr: dateFormatter.string(from: selectedDate), key: self.code)
            }
        }
    }
    @IBAction func cancelClicked(sender: UIButton)
    {
        self.dismiss(animated: true) {
            
        }
    }

}
