//
//  TweetHeartDescriptionCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/28/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class TweetHeartDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var cellTweet:Tweet!{
        didSet {
            fillCell()
        }
    }
    
    func fillCell() {
        updateFavoriteView()
        updateRetweetView()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateFavoriteView(){
        favoriteCountLabel.text = "\(cellTweet.favoritesCount)"
    }
    
    func updateRetweetView(){
        retweetCountLabel.text = "\(cellTweet.retweetCount)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
