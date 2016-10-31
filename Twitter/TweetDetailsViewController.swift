//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/28/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol TweetDetailsViewControllerDelegate {
    @objc optional func tweetUpdated(updatedCellTweet: Tweet, tweetObjIndex: Int)
    @objc optional func tweetComposedFromDetail(composeViewController: ComposeTweetViewController, newTweet: Tweet)
}

class TweetDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetControlsCellDelegate, ComposeTweetViewControllerDelegate {
    
    let cellOneIdentifier = "DescriptionCell"
    let cellTwoIdentifier = "TweetHeartDescriptionCell"
    let cellThreeIdentifier = "TweetControlsCell"
    let cellFourIdentifier = "DescriptionCell"
    
    var tweetObj:Tweet!
    var tweetObjIndex: Int!
    weak var detailDelegate:TweetDetailsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 190
        
        navigationItem.title = "Tweet"
        navigationItem.titleView?.tintColor = UIColor.black
        
        let heartCellNib = UINib(nibName: "TweetHeartDescriptionCell", bundle: nil)
        tableView.register(heartCellNib, forCellReuseIdentifier: cellTwoIdentifier)
        
        let controlsSwitchNib = UINib(nibName: "TweetControlsCell", bundle: nil)
        tableView.register(controlsSwitchNib, forCellReuseIdentifier: cellThreeIdentifier)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return 0.1
        }
        return 32.0
    }
    
    func favoriteRetweetUpdated(updatedCellTweet: Tweet, controlCell: TweetControlsCell) {
        let indexPath = tableView.indexPath(for: controlCell)!
        tweetObj = updatedCellTweet
        let rowIndexPath = IndexPath.init(row: indexPath.row - 1 , section: indexPath.section)
        tableView.reloadRows(at: [rowIndexPath], with: UITableViewRowAnimation.fade)
        detailDelegate?.tweetUpdated!(updatedCellTweet: updatedCellTweet, tweetObjIndex: tweetObjIndex)
    }
    
    func tweetRepliedFromDetail(updatedCellTweet: Tweet, controlCell: TweetControlsCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeTweetViewController
        vc.replyTweet = updatedCellTweet
        vc.newTweetDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        detailDelegate?.tweetComposedFromDetail!(composeViewController: composeViewController, newTweet: newTweet)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellOneIdentifier, for: indexPath) as! DescriptionCell
            cell.tweetDetailObj = tweetObj
            return cell
        }
        else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellTwoIdentifier, for: indexPath) as! TweetHeartDescriptionCell
            cell.cellTweet = tweetObj
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellThreeIdentifier, for: indexPath) as! TweetControlsCell
            cell.cellTweet = tweetObj
            cell.controlDelegate = self
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
