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
}

class TweetCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
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
        //tweetTextLabel.text = cellTweet.text
        tweetTextView.attributedText = hashTagMentions(str: cellTweet.text!)
        
//        let contentSize = tweetTextView.sizeThatFits(tweetTextView.bounds.size)
//        var frame = tweetTextView.frame
//        frame.size.height = contentSize.height
//        
//        CGSize sizeThatFitsTextView = [TextView sizeThatFits:CGSizeMake(TextView.frame.size.width, MAXFLOAT)];
        
        tweetTextView.sizeToFit()
        tweetTextView.layoutIfNeeded()
        let height = tweetTextView.sizeThatFits(CGSize.init(width: tweetTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        tweetTextView.contentSize.height = height
        
        
        if(cellTweet.tweetType == TweetType.Retweet && cellTweet.curUserReTweeted!){
            tweetTypeDescriptionLabel.text = "You retweeted"
            tweetTypeDescriptionImageView.image = UIImage(named: "retweetGreen")
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
    
    //http://stackoverflow.com/questions/35908306/how-to-extract-link-from-uitextview-and-load-image-from-the-link-like-facebook-o
    func hashTagMentions(str:String) -> NSMutableAttributedString  {
        let nsText:NSString = str as NSString
        let words:[String] = nsText.components(separatedBy: " ")
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13.0)
        ]
        
        let attrString = NSMutableAttributedString.init(string: str, attributes: attrs)
        
        // tag each word if it has a hashtag
        for word in words {
            
            if word.hasPrefix("#") {
                
                // a range is the character position, followed by how many characters are in the word.
                let matchRange:NSRange = nsText.range(of: word)
                
                var stringifiedWord:String = word as String
                
                // drop the hashtag
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                
                let digits = NSCharacterSet.decimalDigits
                
                if let numbersExist = stringifiedWord.rangeOfCharacter(from: digits) {
                    // hashtag contains a number, like "#1"so don't make it clickable
                } else {
                    // set a link for when the user clicks on this word.
                    attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/hashtag/\(stringifiedWord)?src=hash", range: matchRange)
                }
                
            }
            if word.hasPrefix("@") {
                let matchRange:NSRange = nsText.range(of: word)
                var stringifiedWord:String = word as String
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                
                let digits = NSCharacterSet.decimalDigits
                if let numbersExist = stringifiedWord.rangeOfCharacter(from: digits) {
                    
                } else {
                    attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/\(stringifiedWord)", range: matchRange)
                }
            }
        }
        return attrString
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
