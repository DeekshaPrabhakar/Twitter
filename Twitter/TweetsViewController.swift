//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/26/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate, TweetDetailsViewControllerDelegate, UIScrollViewDelegate, TweetCellDelegate, ProfileCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var tweets:[Tweet]!
    var refreshControl:UIRefreshControl!
    
    var loadingStateView:LoadingIndicatorView?
    var isDataLoading = false
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var resultsPageOffset = 0
    
    var vcTypeOrEndpoint:String!
    var profileUser:User?
    let profileCellIdentifier = "ProfileCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterLogo = UIImage(named: "TwitterLogoBlue50")
        navigationItem.titleView = UIImageView(image: twitterLogo)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        if(self.parent?.title == "Mentions"){
            vcTypeOrEndpoint = "Mentions"
        }
        else if(self.parent?.title == "Home"){
            vcTypeOrEndpoint = "Home"
        }
        else if(self.parent?.title == "Profile"){
            vcTypeOrEndpoint = "Profile"
        }
        
        if profileUser == nil{
            profileUser = User.currentUser
        }
        
        tableView.tableFooterView = UIView()
        
        //ProfileCell
        let profileCellNib = UINib(nibName: "ProfileCell", bundle: nil)
        tableView.register(profileCellNib, forCellReuseIdentifier: profileCellIdentifier)
        
        setupScrollLoadingMoreIndicator()
        hideNetworkErrorView()
        setupRefreshControl()
        setUpLoadingIndicator()
        showLoadingIndicator()
        getOrRefreshTweets()
    }
    
    func getOrRefreshTweets() {
        showLoadingIndicator()
        let client = TwitterClient.sharedInstance
        
        var lowestTweetID = Int64.max
        if(isMoreDataLoading){// its scroll, fins lowest tweet id
            
            for lTweetObj in tweets
            {
                if(lTweetObj.tweetID < lowestTweetID){
                    lowestTweetID = lTweetObj.tweetID
                }
            }
            lowestTweetID = lowestTweetID - 1
        }
        else{
            lowestTweetID = 0
        }
        
        if(vcTypeOrEndpoint == "Home"){
            
            client.homeTimeline(lowestTweetId: lowestTweetID, success: { (tweets:[Tweet]) in
                
                self.refreshControl.endRefreshing()
                if(self.isMoreDataLoading){
                    self.isMoreDataLoading = false
                    self.tweets.append(contentsOf: tweets)
                    self.loadingMoreView!.stopAnimating()
                }
                else{
                    self.tweets = tweets
                }
                self.tableView.reloadData()
                self.hideLoadingIndicator()
                
                }, failure: {(error : Error) -> () in
                    //print(error.localizedDescription)
                    self.hideLoadingIndicator()
                    self.showNetworkErrorView()
                    self.loadingMoreView!.stopAnimating()
            })
            
        }
        else if(vcTypeOrEndpoint == "Mentions"){
            
            client.userMentions(lowestTweetId: lowestTweetID, success: { (tweets:[Tweet]) in
                
                self.refreshControl.endRefreshing()
                if(self.isMoreDataLoading){
                    self.isMoreDataLoading = false
                    self.tweets.append(contentsOf: tweets)
                    self.loadingMoreView!.stopAnimating()
                }
                else{
                    self.tweets = tweets
                }
                self.tableView.reloadData()
                self.hideLoadingIndicator()
                
                }, failure: {(error : Error) -> () in
                    //print(error.localizedDescription)
                    self.hideLoadingIndicator()
                    self.showNetworkErrorView()
                    self.loadingMoreView!.stopAnimating()
            })
        }//end of mentions
        else if(vcTypeOrEndpoint == "Profile"){
            
            client.userTimeline(lowestTweetId: lowestTweetID,user_id: (profileUser?.userID)! ,success: { (tweets:[Tweet]) in
                
                self.refreshControl.endRefreshing()
                if(self.isMoreDataLoading){
                    self.isMoreDataLoading = false
                    self.tweets.append(contentsOf: tweets)
                    self.loadingMoreView!.stopAnimating()
                }
                else{
                    self.tweets = tweets
                }
                self.tableView.reloadData()
                self.hideLoadingIndicator()
                
                }, failure: {(error : Error) -> () in
                    //print(error.localizedDescription)
                    self.hideLoadingIndicator()
                    self.showNetworkErrorView()
                    self.loadingMoreView!.stopAnimating()
            })
        }//end of Profile
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x:0,y: tableView.contentSize.height, width: tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                getOrRefreshTweets()
            }
        }
    }
    
    func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    func tweetComposedFromDetail(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    func tweetUpdated(updatedCellTweet: Tweet, tweetObjIndex: Int) {
        tweets[tweetObjIndex] = updatedCellTweet
        let rowIndexPath = IndexPath.init(row: tweetObjIndex , section: 0)
        tableView.reloadRows(at: [rowIndexPath], with: UITableViewRowAnimation.fade)
    }
    
    func tweetReplied(updatedCellTweet: Tweet, controlCell: TweetCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewNavController") as! UINavigationController
        
        if let composeViewController = vc.topViewController as? ComposeTweetViewController {
            composeViewController.replyTweet = updatedCellTweet
            composeViewController.newTweetDelegate = self
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func tweetProfileTap(updatedCellTweet: Tweet, controlCell: TweetCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        
        if let profileViewController = vc.topViewController as? TweetsViewController {
            profileViewController.profileUser = updatedCellTweet.user
            profileViewController.vcTypeOrEndpoint = "Profile"
            self.navigationController?.title = "Profile"
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(vcTypeOrEndpoint == "Profile"){
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdentifier, for: indexPath) as! ProfileCell
                cell.profile = profileUser
                cell.profileDelegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
                
                let tweetObj = tweets[indexPath.row - 1]
                cell.cellTweet = tweetObj
                cell.cellDelegate = self
                //cell.tweetTextView.delegate = self
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
            
            let tweetObj = tweets[indexPath.row]
            cell.cellTweet = tweetObj
            cell.cellDelegate = self
            //cell.tweetTextView.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func segmentChanged(tweetType: String, controlCell: ProfileCell) {
        if(tweetType == "Tweets"){
            
        }
        else if(tweetType == "Media"){
            
        }
    }
    
    private func showNetworkErrorView(){
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.networkErrorView.isHidden = false
            self.networkErrorView.frame.size.height = 44
            self.networkErrorView.alpha = 1
            }, completion: nil)
    }
    
    private func hideNetworkErrorView(){
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.networkErrorView.isHidden = true
            self.networkErrorView.frame.size.height = 0
            self.networkErrorView.alpha = 0
            }, completion: nil)
    }
    
    private func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getOrRefreshTweets), for: UIControlEvents.valueChanged)
        let attributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        let attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        refreshControl.tintColor = UIColor.black
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    private func setUpLoadingIndicator(){
        var middleY = UIScreen.main.bounds.size.height/2;
        middleY  = middleY - self.navigationController!.navigationBar.frame.height
        let frame = CGRect(x: 0, y: middleY, width: tableView.bounds.size.width, height: LoadingIndicatorView.defaultHeight)
        loadingStateView = LoadingIndicatorView(frame: frame)
        loadingStateView!.isHidden = true
        tableView.addSubview(loadingStateView!)
    }
    
    func setupScrollLoadingMoreIndicator() {
        let frame = CGRect(x:0, y:tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    private func showLoadingIndicator(){
        isDataLoading = true
        loadingStateView!.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        isDataLoading = false
        loadingStateView!.stopAnimating()
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailViewController = segue.destination as? TweetDetailsViewController{
            if let cell = sender as? UITableViewCell{
                let indexPath = tableView.indexPath(for: cell)
                let tweetObj = tweets![indexPath!.row]
                
                detailViewController.tweetObj = tweetObj
                detailViewController.tweetObjIndex = indexPath!.row
                detailViewController.detailDelegate = self
                detailViewController.navigationItem.leftBarButtonItem?.title = ""
                detailViewController.navigationItem.titleView?.tintColor = UIColor.black
            }
        }
        else if let navController = segue.destination as? UINavigationController {
            if (segue.identifier == "NewTweet"){
                let newTweetVC =  navController.topViewController as! ComposeTweetViewController
                newTweetVC.newTweetDelegate = self
                newTweetVC.segueIdentifier = "NewTweet"
            }
        }
    }
}
