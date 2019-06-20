//
//  FormCell.swift
//  Forms
//
//  Created by Sravan Peddi on 11/06/19.
//

import UIKit

class FormCell: UITableViewCell {

    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var textField : CustomTextView!
    @IBOutlet var textArea : CustomTextView!
    @IBOutlet var dateButton : CustomButton!
    @IBOutlet var dropDownButton : CustomButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (textField != nil){
            textField?.layer.borderWidth = 1.0;
            textField?.layer.borderColor = UIColor.lightGray.cgColor
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
