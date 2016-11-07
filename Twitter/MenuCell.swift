//
//  MenuCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    
    var menuItem:String!{
        didSet {
            fillCell()
        }
    }
    
    func fillCell() {
        menuLabel.text = menuItem
        //"Home", "Mentions", "Profile","Accounts","Logout"
        if(menuItem == "Home"){
            menuImageView.image = UIImage(named: "home")
        }
        else if(menuItem == "Mentions"){
            menuImageView.image = UIImage(named: "alarm")
        }
        else if(menuItem == "Profile"){
            menuImageView.image = UIImage(named: "user")
        }
        else if(menuItem == "Accounts"){
            menuImageView.image = UIImage(named: "users")
        }
        else if(menuItem == "Logout"){
            menuImageView.image = UIImage(named: "logOutWhite")
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
