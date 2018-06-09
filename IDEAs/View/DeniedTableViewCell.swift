//
//  DeniedTableViewCell.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit

class DeniedTableViewCell: UITableViewCell {

    @IBOutlet weak var deniedIDCellLabel: UILabel!
    @IBOutlet weak var deniedTitleCellLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
