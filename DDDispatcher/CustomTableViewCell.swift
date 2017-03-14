//
//  CustomTableViewCell.swift
//  DDDispatcher
//
//  Created by macbookair11 on 3/13/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
