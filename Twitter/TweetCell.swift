//
//  TweetCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/27/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func tweetReplied(updatedCellTweet: Tweet, controlCell: TweetCell)
    @objc optional func tweetProfileTap(updatedCellTweet: Tweet, controlCell: TweetCell)
}

class TweetCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!

    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tweetTypeDescriptionLabel: UILabel!
    @IBOutlet weak var tweetTypeDescriptionImageView: UIImageView!
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    var cellTweet:Tweet!{
        didSet {
            fillCell()
        }
    }
    
    let client = TwitterClient.sharedInstance
    weak var cellDelegate:TweetCellDelegate?
    
    var profileNavController:UIViewController!
    
    func fillCell() {
        if cellTweet.user?.profileUrl != nil {
            profileImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.profileImageView.setImageWith((self.cellTweet.user?.profileUrl!)!)
                self.profileImageView.alpha = 1
                }, completion: nil)

        }
        nameLabel.text = cellTweet.user?.name
        usernameLabel.text = "@" + (cellTweet.user?.screenname!)!
        timeStampLabel.text = cellTweet.timestamp
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
    @IBAction func onProfileButton(_ sender: AnyObject) {
         cellDelegate?.tweetProfileTap!(updatedCellTweet: cellTweet, controlCell: self)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
    }
    @IBAction func onReply(_ sender: AnyObject) {
        cellDelegate?.tweetReplied!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    @IBAction func OnRetweet(_ sender: AnyObject) {
        if(cellTweet.curUserReTweeted)!{
            cellTweet.curUserReTweeted = false
            cellTweet.retweetCount -= 1
            client.UndoRetweet(tweetId: cellTweet.tweetID!, completion: { (response:AnyObject?, error:Error?) in
                if(error != nil){
                    print(error?.localizedDescription)
                    self.cellTweet.curUserReTweeted = true
                    self.cellTweet.retweetCount += 1
                }
                else{
                    print("unfavorited")
                }
                self.updateRetweetView()
            })
        }
        else {
            cellTweet.curUserReTweeted = true
            cellTweet.retweetCount += 1
            
            client.retweetATweet(tweetId: cellTweet.tweetID!, completion: { (response, error) in
                if(error != nil){
                    print("error retweeting tweet")
                    self.cellTweet.curUserReTweeted = false
                    self.cellTweet.retweetCount -= 1
                }
                else{
                    print("retweeted")
                }
                self.updateRetweetView()
            })
        }
    }
    
    @IBAction func onFavoriteOrHeart(_ sender: AnyObject) {
        
        if(cellTweet.curUserFavorited)!{
            cellTweet.curUserFavorited = false
            cellTweet.favoritesCount -= 1
            client.unFavoriteATweet(tweetId: cellTweet.tweetID!, completion: { (response:AnyObject?, error:Error?) in
                if(error != nil){
                    print(error?.localizedDescription)
                    self.cellTweet.curUserFavorited = true
                    self.cellTweet.favoritesCount += 1
                }
                else{
                    print("unfavorited")
                }
                self.updateFavoriteView()
            })
        }
        else {
            cellTweet.curUserFavorited = true
            cellTweet.favoritesCount += 1
            
            client.favoriteATweet(tweetId: cellTweet.tweetID!, completion: { (response, error) in
                if(error != nil){
                    print("error favoriting tweet")
                    self.cellTweet.curUserFavorited = false
                    self.cellTweet.favoritesCount -= 1
                }
                else{
                    print("favorited")
                }
                self.updateFavoriteView()
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
