//
//  SingleTweetCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/6/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class SingleTweetCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetTypeDescriptionLabel: UILabel!
    
    @IBOutlet weak var tweetTypeDescriptionImageView: UIImageView!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var retweetLabel: UILabel!
    
    
    var cellTweet:Tweet!{
        didSet {
            fillCell()
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
    }
    func fillCell() {
        if cellTweet.user?.profileUrl != nil {
            profileImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.profileImageView.setImageWith((self.cellTweet.user?.profileUrl!)!)
                self.profileImageView.alpha = 1
                }, completion: nil)
            
        }
        nameLabel.text = cellTweet.user?.name
        screenNameLabel.text = "@" + (cellTweet.user?.screenname!)!
        timestampLabel.text = cellTweet.timestamp
        tweetTextView.attributedText = Tweet.hashTagMentions(str: cellTweet.text!)
        
        
        tweetTextView.sizeToFit()
        tweetTextView.layoutIfNeeded()
        let height = tweetTextView.sizeThatFits(CGSize.init(width: tweetTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        tweetTextView.contentSize.height = height
        
        
        if(cellTweet.tweetType == TweetType.Retweet){
            if(cellTweet.curUserReTweeted!){
                tweetTypeDescriptionLabel.text = "You retweeted"
                tweetTypeDescriptionImageView.image = UIImage(named: "retweetGreen")
            }
            else{
                tweetTypeDescriptionLabel.text =  "\((cellTweet.retweetedUser?.name)!) retweeted"
                tweetTypeDescriptionImageView.image = UIImage(named: "retweetGray")
            }
            
            tweetTypeDescriptionLabel.isHidden = false
            tweetTypeDescriptionImageView.isHidden = false
        }
        else if(cellTweet.tweetType == TweetType.Reply){
            tweetTypeDescriptionLabel.text = "In reply to " + cellTweet.inReplyToScreenName!
            tweetTypeDescriptionImageView.image = UIImage(named: "replyGray")
            tweetTypeDescriptionLabel.isHidden = false
            tweetTypeDescriptionImageView.isHidden = false
        }
        else{
            tweetTypeDescriptionLabel.text = ""
            tweetTypeDescriptionLabel.isHidden = true
            tweetTypeDescriptionImageView.isHidden = true
        }
        
        updateFavoriteView()
        updateRetweetView()
    }
    func updateFavoriteView(){
        if(cellTweet.curUserFavorited!){
            heartButton.setImage(UIImage(named: "heartRed"), for: .normal)
        }
        else
        {
            heartButton.setImage(UIImage(named: "heartGray"), for: .normal)
        }
        heartLabel.text = "\(cellTweet.favoritesCount)"
    }
    
    func updateRetweetView(){
        if(cellTweet.curUserReTweeted!){
            retweetBtn.setImage(UIImage(named: "retweetGreen"), for: .normal)
        }
        else{
            retweetBtn.setImage(UIImage(named: "retweetGray"), for: .normal)
        }
        retweetLabel.text = "\(cellTweet.retweetCount)"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
