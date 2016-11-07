//
//  LoginViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/24/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 6
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        let client = TwitterClient.sharedInstance
        client.login(success: {
            print("loggedin")
            //self.performSegue(withIdentifier: "loginSegue", sender: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let hamburgerVC = storyboard.instantiateViewController(withIdentifier: "HamburgerVC") as! HamburgerViewController
            let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuViewController
            
            menuVC.hamburgerViewController = hamburgerVC
            hamburgerVC.menuViewController = menuVC
            
            self.present(hamburgerVC, animated: true, completion: nil)
            
        }) { (error: Error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
