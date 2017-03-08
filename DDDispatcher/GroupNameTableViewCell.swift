

//
//  GroupNameTableViewCell.swift
//  DDDispatcher
//
//  Created by Neel A on 2/27/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class GroupNameTableViewCell: UITableViewCell {
    
    @IBOutlet var groupImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
