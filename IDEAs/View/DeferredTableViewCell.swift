//
//  DeferredTableViewCell.swift
//  IDEAs
//
//  Created by Jared Boynton on 6/11/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit

class DeferredTableViewCell: UITableViewCell {

    
    @IBOutlet weak var deferredIdeaIDOutlet: UILabel!
    
    @IBOutlet weak var deferredIdeaTitleOutlet: UILabel!
    
    @IBOutlet weak var deferredDescriptionLabel: UILabel!
    
    @IBOutlet weak var deferredDateLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
