//
//  ActiveTableViewCell.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit

class ActiveTableViewCell: UITableViewCell {

    @IBOutlet weak var ideaIDCellLabel: UILabel!
    
    @IBOutlet weak var ideaTitleCellLabel: UILabel!
    
    @IBOutlet weak var ideaDescriptionLabel: UILabel!
    
    @IBOutlet weak var ideaDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
