//
//  ProfileHeaderCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var tagLine: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var profile:User!{
        didSet {
            fillCell()
        }
    }
    
    func fillCell() {
        if profile.profileUrl != nil {
            profileImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.profileImageView.setImageWith(self.profile.profileUrl!)
                self.profileImageView.alpha = 1
                }, completion: nil)
        }
        
        profileImageView.layer.cornerRadius = 6
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.masksToBounds = true
        
        profileName.text = profile.name
        screenName.text = "@" + (profile.screenname!)
        tagLine.text = profile.tagline
        
        locationLabel.text = profile.location
        followingCountLabel.text = "\(profile.followingCount)"
        followersCountLabel.text = "\(profile.followersCount)"
    }
    
    
    @IBAction func onPageChange(_ sender: UISegmentedControl) {
        
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
