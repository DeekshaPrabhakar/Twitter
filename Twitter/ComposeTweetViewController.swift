//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/28/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol ComposeTweetViewControllerDelegate {
    @objc optional func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var replyToStackView: UIStackView!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var composeTweetTextView: UITextView!
    @IBOutlet weak var replyToStackHeightConstraint: NSLayoutConstraint!
    
    let client = TwitterClient.sharedInstance
    
    weak var newTweetDelegate:ComposeTweetViewControllerDelegate?
    var segueIdentifier:String?
    var replyTweet:Tweet?
    var replyToTweetPrefix:String?
    
    let tweetLimit = 140
    var loadingStateView:LoadingIndicatorView?
    var isDataLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        composeTweetTextView.delegate = self
        
        tweetButton.layer.cornerRadius = 5
        tweetButton.clipsToBounds = true
        self.automaticallyAdjustsScrollViewInsets = false
        tweetButton.isEnabled = false
        tweetButton.backgroundColor = UIColor.white
        tweetButton.layer.borderColor = UIColor.lightGray.cgColor
        tweetButton.layer.borderWidth = 0.5
        
        if(segueIdentifier == "NewTweet"){
            composeTweetTextView.text = "What's happening?"
            composeTweetTextView.textColor = UIColor.lightGray
            replyToStackHeightConstraint.constant = 0
            view.layoutIfNeeded()
            composeTweetTextView.becomeFirstResponder()
        }
        else{
            if let replyTweet = replyTweet {
                replyToStackHeightConstraint.constant = 30
                view.layoutIfNeeded()
                replyToTweetPrefix = "@\((replyTweet.user?.screenname)!)"
                replyToLabel.text = "In reply to \((replyTweet.user?.screenname)!)"
                composeTweetTextView.text = replyToTweetPrefix! + " "
                composeTweetTextView.textColor = UIColor.black
                composeTweetTextView.becomeFirstResponder()
                
            }
        }
        
        setUpLoadingIndicator()
        hideLoadingIndicator()
    }
    
    func configureNavBar(){
        
        if let profileImageUrl = User.currentUser?.profileUrl{
       
            let profileImage = UIImage()
            let profileImageView = UIImageView(image: profileImage)
            profileImageView.setImageWith(profileImageUrl)
            profileImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            profileImageView.layer.cornerRadius = 3
            profileImageView.layer.masksToBounds = true
            
            let leftbarButton = UIBarButtonItem.init(customView: profileImageView)
            self.navigationItem.leftBarButtonItem = leftbarButton
        }
        
        let closeImageView = UIImageView(image: UIImage(named: "close"))
        closeImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let rightbarButton = UIBarButtonItem.init(customView: closeImageView)
        self.navigationItem.rightBarButtonItem = rightbarButton
        
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(onCancelCompose))
        closeTap.numberOfTapsRequired = 1
        closeImageView.addGestureRecognizer(closeTap)
    }
    
    @IBAction func onComposeTweet(_ sender: AnyObject) {
        showLoadingIndicator()
        var twText = composeTweetTextView.text!
        var replyToID = Int64.max
        if(replyTweet != nil){
            twText = replyToTweetPrefix! + composeTweetTextView.text!
            replyToID = (replyTweet?.tweetID)!
        }
        else
        {
            replyToID = 0
        }
        
        if(composeTweetTextView.text.characters.count > 0)
        {
            client.composeTweet(tweetText: twText, inReplyTo: Int64(replyToID)) { (response, error) in
                if(error != nil){
                    print(error?.localizedDescription)
                    self.hideLoadingIndicator()
                }
                else{
                    self.hideLoadingIndicator()
                    let tweetRes = Tweet(dictionary: response as! NSDictionary)
                    print(tweetRes)
                    self.newTweetDelegate?.tweetComposed!(composeViewController: self, newTweet: tweetRes)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentLength = composeTweetTextView.text.characters.count
        
        if(currentLength > 0){
            tweetButton.backgroundColor = UIColor.init(red: CGFloat(29)/255, green: CGFloat(161)/255, blue: CGFloat(242)/255, alpha: 1)
            tweetButton.tintColor = UIColor.white
            tweetButton.isEnabled = true
            tweetButton.layer.borderColor = UIColor.init(red: CGFloat(29)/255, green: CGFloat(161)/255, blue: CGFloat(242)/255, alpha: 1).cgColor
        }
        else{
             tweetButton.backgroundColor = UIColor.white
             tweetButton.tintColor = UIColor.lightGray
            tweetButton.isEnabled = false
            tweetButton.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        if(range.length + range.location > currentLength)
        {
            return false
        }
        let newLength = currentLength + text.characters.count - range.length
        let newLenghtAllowed = newLength <= tweetLimit
        if newLenghtAllowed {
            tweetCountLabel.text = "\(tweetLimit - newLength)"
        }
        
        return newLenghtAllowed
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        composeTweetTextView.setContentOffset(CGPoint.zero, animated: false)
        if composeTweetTextView.textColor == UIColor.lightGray {
            composeTweetTextView.text = nil
            composeTweetTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if composeTweetTextView.text.isEmpty {
            composeTweetTextView.text = "What's happening?"
            composeTweetTextView.textColor = UIColor.lightGray
        }
    }
    
    func onCancelCompose(){
        dismiss(animated: true, completion: nil)
    }
    
    
    private func setUpLoadingIndicator(){
        var middleY = UIScreen.main.bounds.size.height/2;
        if(self.navigationController != nil){
            middleY  = middleY - self.navigationController!.navigationBar.frame.height
        }
        let frame = CGRect(x: 0, y: middleY, width: self.view.bounds.size.width, height: LoadingIndicatorView.defaultHeight)
        loadingStateView = LoadingIndicatorView(frame: frame)
        loadingStateView!.isHidden = true
        self.view.addSubview(loadingStateView!)
    }
    
    private func showLoadingIndicator(){
        isDataLoading = true
        loadingStateView!.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        isDataLoading = false
        loadingStateView!.stopAnimating()
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
