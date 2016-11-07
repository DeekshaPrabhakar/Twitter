//
//  AccountsViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/6/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol AccountsViewControllerDelegate {
    @objc optional func switchAccount(switchToUser: User)
    @objc optional func addAccount()
}

class AccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccountCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let accountCellIdentifier = "AccountCell"
    let addAccountCellIdentifier = "AddAccountCell"
    var accounts:NSArray!
    var panningOnCell:AccountCell?
    weak var accountsVCDelegate:AccountsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let accountCellNib = UINib(nibName: "AccountCell", bundle: nil)
        tableView.register(accountCellNib, forCellReuseIdentifier: accountCellIdentifier)
        //AddAccountCell
        let addAccountCellNib = UINib(nibName: "AddAccountCell", bundle: nil)
        tableView.register(addAccountCellNib, forCellReuseIdentifier: addAccountCellIdentifier)
        
        accounts = User.accounts()
        //setUpNavBar()
        tableView.tableFooterView = UIView()
    }
    
    func setUpNavBar(){
        if (User.currentUser != nil) {
                       // set up title with long press gesture recognizer
            
            let navLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
                navLabel.text = User.currentUser?.name
            navLabel.textAlignment = NSTextAlignment.center
            navLabel.textColor = UIColor.black
            navLabel.isUserInteractionEnabled = true
            self.navigationItem.titleView = navLabel
            
            let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(onNavBarLongPress))
            
           navLabel.addGestureRecognizer(longPressGesture)
        } else {
            //self.navigationItem.title = user.name;
        }
    }
    
    func onNavBarLongPress(){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < accounts.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: accountCellIdentifier, for: indexPath) as! AccountCell
            cell.accountUser = accounts[indexPath.row] as! User
            cell.accountCellDelegate = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: addAccountCellIdentifier, for: indexPath) as! AddAccountCell
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row < accounts.count){
            accounts = User.accounts()
            accountsVCDelegate?.switchAccount!(switchToUser: accounts[indexPath.row] as! User)
        } else {
            accountsVCDelegate?.addAccount!()
        }
    }
    
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        let indexPath = tableView.indexPathForRow(at: location)
        if ((indexPath != nil) && (indexPath?.row)! < User.accounts().count) {
            panningOnCell = (tableView.cellForRow(at: indexPath!) as! AccountCell)
            panningOnCell?.onPan(sender: sender, location: location, translation: translation, velocity: velocity)
        }
    }
    
    func deleteAccount(userToDelete: User, controlCell: AccountCell) {
        User.removeUser(user: userToDelete)
        accounts = User.accounts()
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
        if(User.accounts().count == 0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
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
