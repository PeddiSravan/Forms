//
//  HistoryCell.swift
//  Forms
//
//  Created by Surendra Ponnapalli on 08/12/19.
//

import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
