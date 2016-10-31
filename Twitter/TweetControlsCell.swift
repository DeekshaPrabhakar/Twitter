//
//  TweetControlsCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/28/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol TweetControlsCellDelegate {
    @objc optional func favoriteRetweetUpdated(updatedCellTweet: Tweet, controlCell: TweetControlsCell)
    @objc optional func tweetRepliedFromDetail(updatedCellTweet: Tweet, controlCell: TweetControlsCell)
}

class TweetControlsCell: UITableViewCell {
    
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    var cellTweet:Tweet!{
        didSet {
            fillCell()
        }
    }
    
    let client = TwitterClient.sharedInstance
    weak var controlDelegate:TweetControlsCellDelegate?
    
    func fillCell() {
        updateFavoriteView()
        updateRetweetView()
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        controlDelegate?.tweetRepliedFromDetail!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func onRetweet(_ sender: AnyObject) {
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
    
    @IBAction func onFavorite(_ sender: AnyObject) {
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
    
    func updateFavoriteView(){
        if(cellTweet.curUserFavorited!){
            heartButton.setImage(UIImage(named: "heartRed"), for: .normal)
        }
        else
        {
            heartButton.setImage(UIImage(named: "heartGray"), for: .normal)
        }
        controlDelegate?.favoriteRetweetUpdated!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    func updateRetweetView(){
        if(cellTweet.curUserReTweeted!){
            retweetBtn.setImage(UIImage(named: "retweetGreen"), for: .normal)
        }
        else{
            retweetBtn.setImage(UIImage(named: "retweetGray"), for: .normal)
        }
        controlDelegate?.favoriteRetweetUpdated!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    
    @IBAction func onEmail(_ sender: AnyObject) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
