//
//  FormCell.swift
//  Forms
//
//  Created by Sravan Peddi on 11/06/19.
//

import UIKit

class FormCell: UITableViewCell {

    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var textField : UITextField!
    @IBOutlet var textArea : UITextView!
    @IBOutlet var dateButton : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (textField != nil){
            textField?.layer.borderWidth = 1.0;
            textField?.layer.borderColor = UIColor.gray.cgColor
        }
        if (textArea != nil){
            textArea?.layer.borderWidth = 1.0;
            textArea?.layer.borderColor = UIColor.gray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
