//
//  Post.swift
//  Barkd1
//
//  Created by MacBook Air on 3/18/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _postUser: String!
    private var _profilePicURL: String!
    private var _currentDate: String!
    private var _uid: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postUser: String {
        return _postUser
    }
    
    var profilePicURL: String {
        return _profilePicURL
    }
    
    var currentDate: String {
        return _currentDate
    }
    
    var uid: String {
        return _uid
    }
    
    var postKey: String {
        return _postKey
    }
    
    
    init(caption: String, imageURL: String, likes: Int, postUser: String, profilePicURL: String, currentDate: String, uid: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
        self._postUser = postUser
        self._uid = uid
        self._profilePicURL = profilePicURL
        self._currentDate = currentDate
    }
    
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let postUser = postData["postUser"] as? String {
            self._postUser = postUser
        }
        
        if let profilePicURL = postData["profilePicURL"] as? String {
            self._profilePicURL = profilePicURL
        }
        
        if let currentDate =
            postData["currentDate"] as? String {
            self._currentDate = currentDate
        }
        
        if let uid =
            postData["uid"] as? String {
            self._uid = uid
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
}
