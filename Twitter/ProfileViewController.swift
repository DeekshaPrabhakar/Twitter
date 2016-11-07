//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabelHandle: UILabel!
    
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var headerLabelHandleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label
    
    
    var profile:User?
    var tweets:[Tweet]!
    let singleTweetCellIdentifier = "SingleTweetCell"
    
    func fillCell() {
        //view.layoutIfNeeded()
        if profile!.profileUrl != nil {
            profileImageView.setImageWith(self.profile!.profileUrl!)
        }
        
        nameLabelHandle.text = profile!.name
        headerLabel.text = profile!.name
        screenNameLabel.text = "@" + (profile!.screenname!)
        //locationLabel.text = profile!.location
        // followingCountLabel.text = "\(profile!.followingCount)"
        //followersCountLabel.text = "\(profile!.followersCount)"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 105;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        //SingleTweetCell
        let singleTweetCellNib = UINib(nibName: "SingleTweetCell", bundle: nil)
        tableView.register(singleTweetCellNib, forCellReuseIdentifier: singleTweetCellIdentifier)
        
        profileImageView.layer.cornerRadius = 6
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.masksToBounds = true
        
        fillCell()
        getOrRefreshTweets()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Header - Image
        
        headerImageView = UIImageView(frame: headerView.bounds)
        headerImageView.setImageWith(profile!.bannerImageUrl!)
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        // headerBlurImageView?.image = UIImage(named: "header_bg")?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        
        headerBlurImageView.setImageWith(profile!.bannerImageUrl!)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = headerBlurImageView!.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        headerBlurImageView?.addSubview(blurEffectView)

        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        headerView.clipsToBounds = true
        headerView.isHidden = false
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height , 0, 0, 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        let cell = tableView.dequeueReusableCell(withIdentifier: singleTweetCellIdentifier, for: indexPath) as! SingleTweetCell
        
        let tweetObj = tweets[indexPath.row]
        cell.cellTweet = tweetObj
        //cell.cellDelegate = self
        //cell.tweetTextView.delegate = self
        return cell
        
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
            
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            headerLabel.isHidden = false
            let alignToNameLabel = -offset + nameLabelHandle.frame.origin.y + headerView.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((profileImageView.bounds.height * (1.0 + avatarScaleFactor)) - profileImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if profileImageView.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
                
                
            }else {
                if profileImageView.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
                
            }
            
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        profileImageView.layer.transform = avatarTransform
        
        // Segment control
        
        let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
        
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        
        segmentedView.layer.transform = segmentTransform
        
        
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
        
        
        
    }
    
    func getOrRefreshTweets() {
        
        let client = TwitterClient.sharedInstance
        
        var lowestTweetID = Int64.max
        lowestTweetID = 0
        
        
        client.userTimeline(lowestTweetId: lowestTweetID,user_id: (profile?.userID)! ,success: { (tweets:[Tweet]) in
            
            self.tweets = tweets
            self.tableView.reloadData()
            
            }, failure: {(error : Error) -> () in
                //print(error.localizedDescription)
                
        })
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
