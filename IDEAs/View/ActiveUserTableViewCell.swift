//
//  ActiveUserTableViewCell.swift
//  IDEAs
//
//  Created by Jared Boynton on 6/14/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Spring

class ActiveUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameTextField: UILabel!
    
    @IBOutlet weak var onlineStatusIndicator: SpringView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
