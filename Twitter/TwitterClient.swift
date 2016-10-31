//
//  TwitterClient.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/26/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com") as URL!, consumerKey: "mDfbHJSlu1nN1up1HggY92aQ9", consumerSecret: "fKSAb4J1aVDjgYXRUNd4r7EjYvp3Zb4IggW9QmSa8L2tBOM5uk")!
    var loginSuccess:(() -> ())?
    var loginFailure:((Error) -> ())?
    
    func login(success:@escaping () -> (), failure:@escaping (Error) -> ()){
        
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize() //clears keychain of previous sessions
        self.requestSerializer.removeAccessToken()
        
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: NSURL(string: "deekshaTwitter://oauth") as URL!, scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            print("got token")
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
            UIApplication.shared.open(url as URL!, options: [:], completionHandler: { (success: Bool) in
                //print
            })
            }, failure: { (error:Error?) in
                self.loginFailure?(error!)
        })
    }
    
    func  logout() {
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL)
    {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken:BDBOAuth1Credential?) -> Void in
            self.requestSerializer.saveAccessToken(accessToken)
            self.currentAccount(success: { (user:User) in
                User.currentUser = user
                self.loginSuccess?()
                
                }, failure: { (error:Error) in
                    self.loginFailure?(error)
            })
            
            },failure: { (error: Error?) in
                self.loginFailure?(error!)
        })
    }
    
    func homeTimeline(lowestTweetId: Int64, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        
        var qParams = ["count": 20] as [String: Any]
        
        if(lowestTweetId != 0){
            qParams = ["count": 20, "max_id" : String(lowestTweetId)] as [String: Any]
        }
        
        get("1.1/statuses/home_timeline.json", parameters: qParams, progress: nil, success: { (task:URLSessionDataTask, response:Any?) -> Void in
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            success(tweets)
            
            }, failure: { (tsk:URLSessionDataTask?, err:Error) -> Void in
                failure(err)
        })
    }
    
    func favoriteATweet(tweetId: Int64, completion:@escaping (_ resp:AnyObject?, _ error:Error?) ->())
    {
        post("1.1/favorites/create.json?id=\(tweetId)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            
            completion(response as AnyObject? , nil)
            
            }, failure: { (task:URLSessionDataTask?, err:Error) -> Void in
                completion(nil, err)
        })
    }
    
    func unFavoriteATweet(tweetId: Int64, completion:@escaping (_ resp:AnyObject?, _ error:Error?) ->())
    {
        let params = ["id": "\(tweetId)"]
        post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            
            completion(response as AnyObject? , nil)
            
            }, failure: { (task:URLSessionDataTask?, err:Error) -> Void in
                completion(nil, err)
        })
    }
    
    func retweetATweet(tweetId: Int64, completion:@escaping (_ response:AnyObject?, _ error:Error?)->())
    {
        post("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            
            completion(response as AnyObject? , nil)
            
            }, failure: { (task:URLSessionDataTask?, err:Error) -> Void in
                completion(nil, err)
        })
    }
    
    func UndoRetweet(tweetId: Int64, completion:@escaping (_ response:AnyObject?, _ error:Error?)->())
    {
        post("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            completion(response as AnyObject? , nil)
            }, failure: { (task:URLSessionDataTask?, err:Error) -> Void in
                completion(nil, err)
        })
    }
    
    func composeTweet(tweetText: String, inReplyTo:Int64, completion:@escaping (_ response:AnyObject?, _ error:Error?)->())
    {
        var params = ["status": tweetText, "in_reply_to_status_id": "\(inReplyTo)"] as [String: Any]
        if(inReplyTo == 0)
        {
            params = ["status": tweetText, "in_reply_to_status_id": ""] as [String: Any]
        }
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            completion(response as AnyObject? , nil)
            }, failure: { (task:URLSessionDataTask?, err:Error) -> Void in
                completion(nil, err)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (_task:URLSessionDataTask, response:Any?) -> Void in
            
            let userDictionary = response as? NSDictionary
            let user = User(dictionary: userDictionary!)
            success(user)
            
            }, failure: { (task :URLSessionDataTask?, error:Error) -> Void in
                
                print(error)
                failure(error)
        })
    }
}
