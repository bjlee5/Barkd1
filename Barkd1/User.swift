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

struct User {
    
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
