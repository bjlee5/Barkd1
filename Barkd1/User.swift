//
//  User.swift
//  Barkd1
//
//  Created by MacBook Air on 3/17/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// Update ** this is crashing when I navigate to this page for a user who's created an account without one of the required fields. For example, someone logging in via facebook does not have a username or profile pic yet. Or someone creating an account by signing in does not either //

struct Users {
    
    var username: String!
    var email: String?
    var bio: String?
    var photoURL: String!
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        ref = snapshot.ref
        username = (snapshot.value! as! NSDictionary)["username"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        bio = (snapshot.value! as! NSDictionary)["bio"] as? String
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
    }
    
}

