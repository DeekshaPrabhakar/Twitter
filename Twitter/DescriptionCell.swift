//
//  DescriptionCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/28/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var tweetDetailObj: Tweet! {
        didSet {
            fillCell()
        }
    }
    
    func fillCell() {
        if tweetDetailObj.user?.profileUrl != nil {
            profileImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.profileImageView.setImageWith((self.tweetDetailObj.user?.profileUrl!)!)
                self.profileImageView.alpha = 1
                }, completion: nil)
        }
        nameLabel.text = tweetDetailObj.user?.name
        screenNameLabel.text = "@" + (tweetDetailObj.user?.screenname!)!
        timestampLabel.text = tweetDetailObj.createdAt
        tweetTextLabel.text = tweetDetailObj.text
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
