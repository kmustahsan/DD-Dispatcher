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
    let userInfo = Cache.sharedInstance.getValueForKey(key: "User") as! [String: Any]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .black
        let url = NSURL(string: userInfo["avatar"] as! String)
        let task = URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "Session error")
                return
            }
            DispatchQueue.main.async {
                self.profileAvatar.image = UIImage(data: data!)
                self.profileAvatar.layer.cornerRadius = self.profileAvatar.frame.size.width / 2;
                self.profileAvatar.clipsToBounds = true;
            }
        })
        task.resume()
        
        if let userName = userInfo["name"]  {
            username.text! = userName as! String
            username.textColor = .white
        } else {
            username.text! = "None"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
