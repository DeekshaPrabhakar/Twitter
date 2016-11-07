//
//  ProfileCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol ProfileCellDelegate {
    @objc optional func segmentChanged(tweetType: String, controlCell: ProfileCell)
}


class ProfileCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tagLineLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
     weak var profileDelegate:ProfileCellDelegate?
    
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
        
        if let bgUrl = profile?.bannerImageUrl{
            bgImageView.setImageWith(bgUrl)
            bgImageView.clipsToBounds = true
            //bgImageView.contentMode = .scaleAspectFill
        }
        
        
        profileName.text = profile.name
        screenName.text = "@" + (profile.screenname!)
        tagLineLabel.text = profile.tagline
        
        locationLabel.text = profile.location
        followingLabel.text = "\(profile.followingCount)"
        followersLabel.text = "\(profile.followersCount)"
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 6
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.masksToBounds = true

    }
  
    @IBAction func onTweetTypeChange(_ sender: UISegmentedControl) {
        let type = sender.titleForSegment(at: sender.selectedSegmentIndex)
        profileDelegate?.segmentChanged!(tweetType: type!, controlCell: self)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
