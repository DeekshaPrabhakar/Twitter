//
//  MenuViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccountsViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var profileNavController:ProfileViewController!
    private var homeTimeLineNavController:UIViewController!
    private var mentionsNavController:UIViewController!
    private var accountsNavController:UINavigationController!
    
    var viewControllers:[UIViewController] = []
    let titles = ["Home", "Mentions", "Profile","Accounts","Logout"]
    var hamburgerViewController: HamburgerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        initViewControllers()
    }
    
    func initViewControllers() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
         profileNavController = storyboard.instantiateViewController(withIdentifier: "ProfileController") as! ProfileViewController
        //profileNavController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        //profileNavController = ProfileNewViewController(nibName: "ProfileNewViewController", bundle: nil)
        profileNavController.profile = User.currentUser
        profileNavController.title = "Profile"
        homeTimeLineNavController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        homeTimeLineNavController.title = "Home"
        mentionsNavController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        mentionsNavController.title = "Mentions"
        //accountsNavController = storyboard.instantiateViewController(withIdentifier: "AccountsNavViewController") as! UINavigationController
        
        accountsNavController = storyboard.instantiateViewController(withIdentifier: "AccountsNavViewController") as! UINavigationController
        
        if let accountsController = accountsNavController.topViewController as? AccountsViewController {
            accountsController.accountsVCDelegate = self
        }
        
        
        viewControllers.append(homeTimeLineNavController)
        viewControllers.append(mentionsNavController)
        viewControllers.append(profileNavController)
        viewControllers.append(accountsNavController)
        
        hamburgerViewController.contentViewController = homeTimeLineNavController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.menuItem = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(titles[indexPath.row] == "Logout"){
            TwitterClient.sharedInstance.logout()
        }else{
            hamburgerViewController.contentViewController = viewControllers[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = Int.init(self.view.frame.height)/titles.count
        return CGFloat.init(rowHeight)
    }
    
    func addAccount() {
       
    }
    
    func switchAccount(switchToUser: User) {
        
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
