//
//  FormCell.swift
//  Forms
//
//  Created by Sravan Peddi on 11/06/19.
//

import UIKit

class FormCell: UITableViewCell {

    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var textField : CustomTextField!
    @IBOutlet var textArea : CustomTextView!
    @IBOutlet var dateButton : CustomButton!
    @IBOutlet var dropDownButton : CustomButton!
    @IBOutlet var checkBox: CustomSwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (textField != nil){
            textField?.layer.borderWidth = 1.0;
            textField?.layer.borderColor = UIColor.lightGray.cgColor
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: textField.frame.size.height))
            textField?.leftView = paddingView
            textField?.leftViewMode = .always
        }
        if (textArea != nil){
            textArea?.layer.borderWidth = 1.0;
            textArea?.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
