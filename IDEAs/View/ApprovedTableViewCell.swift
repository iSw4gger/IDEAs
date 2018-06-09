//
//  ApprovedTableViewCell.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit

class ApprovedTableViewCell: UITableViewCell {

    @IBOutlet weak var approvedIdeaIDOutlet: UILabel!
    
    @IBOutlet weak var approvedIdeaTitleOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
