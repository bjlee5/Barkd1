
//
//  PostCellTableViewCell.swift
//  Barkd1
//
//  Created by MacBook Air on 3/18/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var likesNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
