//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/26/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    var tweets:[Tweet]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TwitterClient.sharedInstance
        
        client.homeTimeline(success: { (tweets:[Tweet]) in
            self.tweets = tweets
            }, failure: {(error : Error) -> () in
                print(error.localizedDescription)
        })
    
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
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
