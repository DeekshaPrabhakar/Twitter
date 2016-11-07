//
//  AccountCell.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 11/6/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

@objc protocol AccountCellDelegate {
    @objc optional func deleteAccount(userToDelete: User, controlCell: AccountCell)
}

class AccountCell: UITableViewCell {
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountScreenNameLabel: UILabel!
    
    @IBOutlet weak var accountViewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountView: UIView!
    var panReferenceX:CGFloat!
    
    weak var accountCellDelegate:AccountCellDelegate?
    
    
    var accountUser:User!{
        didSet {
            fillCell()
        }
    }
    
    func fillCell() {
        accountNameLabel.text = accountUser.name
        if let pfUrl = accountUser.profileUrl {
            accountImageView.setImageWith(pfUrl)
            accountImageView.clipsToBounds = true
        }
        accountScreenNameLabel.text = accountUser.screenname
    }
    
    
    func onPan(sender:UIGestureRecognizer, location: CGPoint, translation:CGPoint, velocity:CGPoint) {
        
        if (sender.state == .began) {
            panReferenceX = accountViewXConstraint.constant
        } else if (sender.state == .changed) {
            // move, lighten, spin, and shrink as you pan
            self.accountViewXConstraint.constant = self.panReferenceX - translation.x
            accountView.alpha = 1 - (translation.x / 200);
            accountView.transform = CGAffineTransform(scaleX: 1 - (translation.x / 700), y: 1 - (translation.x / 700))
        } else if (sender.state == .ended) {
            // only delete if velocity is more than 200 and translation is more than 100
            if (velocity.x >= 300 && translation.x >= 100) {
                //NSLog(@"Delete account via pan");
                accountCellDelegate?.deleteAccount!(userToDelete: self.accountUser, controlCell: self)
            } else {
                // animate back to original
                UIView.animate(withDuration: 0.30, animations: {
                    self.accountViewXConstraint.constant = 0
                    self.accountView.alpha = 1
                    self.accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accountImageView.layer.cornerRadius = 6
        accountImageView.layer.borderColor = UIColor.white.cgColor
        accountImageView.layer.borderWidth = 3
        accountImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
