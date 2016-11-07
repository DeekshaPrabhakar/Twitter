//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/5/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    var originalLeftMargin:CGFloat!
    var menuViewController:UIViewController!{
        didSet(oldMenuViewController){
            view.layoutIfNeeded()
            
            if(oldMenuViewController != nil){
                oldMenuViewController.willMove(toParentViewController: nil)
                oldMenuViewController.view.removeFromSuperview()
                oldMenuViewController.didMove(toParentViewController: nil)
            }
            
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
            
            //bookkeeping to be added for view rotation methods
        }
    }
    
    var contentViewController:UIViewController!{
        didSet(oldContentViewController){
            view.layoutIfNeeded()
            
            if(oldContentViewController != nil){
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            
            //bookkeeping to be added for view rotation methods
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if(sender.state == .began){
            originalLeftMargin = leftMarginConstraint.constant
        }
        else if(sender.state == .changed){
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        }
        else if(sender.state == .ended){
            
            UIView.animate(withDuration: 0.3, animations: {
                //animate autolayout, cant change the frame within autolayout instead changing constraints
                if(velocity.x > 0){//opening menu
                    self.leftMarginConstraint.constant = self.view.frame.width - 50
                }
                else{//closing menu
                    self.leftMarginConstraint.constant = 0
                }
                //then call this: here self.view is the parent of the view who's constraints you are changing
                self.view.layoutIfNeeded()
            })
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
